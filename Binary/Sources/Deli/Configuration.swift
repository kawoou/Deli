//
//  Configuration.swift
//  Deli
//

import Foundation
import xcodeproj
import Yams

enum ConfigurationError: Error {
    case projectNotFound
    case projectCannotOpen
    case schemeCannotLoad
    case buildTargetNotFound
    case buildTargetAmbiguous
}

final class Configuration {

    private typealias BuildableReference = (id: String, name: String)

    // MARK: - Constant

    private struct Constant {
        static let configFile = "deli.yml"
        static let className = "DeliFactory"
        static let outputFile = "\(className).swift"

        static let xcodeProjectExtension = "xcodeproj"
        static let xcodeSchemeExtension = "xcscheme"
    }

    // MARK: - Private

    private let fileManager = FileManager.default
    private lazy var basePath = self.fileManager.currentDirectoryPath

    private func findPath(_ fileName: String) -> String? {
        guard let baseURL = URL(string: basePath) else { return nil }

        let fileURL = baseURL.appendingPathComponent(fileName).standardized
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        return fileURL.path
    }

    private func convertToProjectFile(_ project: String) -> String {
        if project.hasSuffix(Constant.xcodeProjectExtension) {
            return project
        } else {
            return "\(project).\(Constant.xcodeProjectExtension)"
        }
    }

    private func findBuildReference(for schemeName: String, project: XcodeProj) -> BuildableReference? {
        let schemeList = project.sharedData?.schemes
            .filter { $0.name == schemeName } ?? []

        guard let scheme = schemeList.first else {
            Logger.log(.error("Not found `\(schemeName)` scheme. Please check again if set shared.", nil))
            return nil
        }
        guard schemeList.count == 1 else {
            let schemeMessage = schemeList
                .map { $0.name }
                .joined(separator: ", ")

            Logger.log(.debug("Ambiguous shared build scheme: \(schemeMessage)"))
            Logger.log(.error("Ambiguous shared build scheme.", nil))
            return nil
        }

        guard let buildAction = scheme.buildAction?.buildActionEntries.first else {
            Logger.log(.error("Not found build target.", nil))
            return nil
        }
        return (
            id: String(buildAction.buildableReference.blueprintIdentifier.hashValue),
            name: buildAction.buildableReference.buildableName
        )
    }
    private func findBuildReference(project: XcodeProj) -> BuildableReference? {
        let schemeList = project.sharedData?.schemes ?? []

        guard let scheme = schemeList.first else {
            guard let nativeTarget = project.pbxproj.objects.nativeTargets.first else {
                Logger.log(.error("Not found build target.", nil))
                return nil
            }
            guard project.pbxproj.objects.nativeTargets.count == 1 else {
                let targetMessage = project.pbxproj.objects.nativeTargets.values
                    .map { $0.name }
                    .joined(separator: ", ")

                Logger.log(.debug("Ambiguous build target: \(targetMessage)"))
                Logger.log(.error("Ambiguous build target.", nil))
                return nil
            }
            return (
                id: String(nativeTarget.key.hashValue),
                name: nativeTarget.value.name
            )
        }

        guard schemeList.count == 1 else {
            let schemeMessage = schemeList
                .map { $0.name }
                .joined(separator: ", ")

            Logger.log(.debug("Ambiguous shared build scheme: \(schemeMessage)"))
            Logger.log(.error("Ambiguous shared build scheme.", nil))
            return nil
        }

        guard let buildAction = scheme.buildAction?.buildActionEntries.first else {
            Logger.log(.error("Not found build target.", nil))
            return nil
        }
        return (
            id: String(buildAction.buildableReference.blueprintIdentifier.hashValue),
            name: buildAction.buildableReference.buildableName
        )
    }

    private func parseFileTree(group: PBXGroup, project: XcodeProj, stackedPath: [String] = []) -> [String: String] {
        var stackedPath = stackedPath
        var filePath = [String: String]()

        for groupKey in group.childrenReferences {
            guard let group = project.pbxproj.objects.groups[groupKey] else {
                if let path = project.pbxproj.objects.fileReferences[groupKey]?.path {
                    stackedPath.append(path)
                    filePath[String(groupKey.hashValue)] = stackedPath.joined(separator: "/")
                    _ = stackedPath.popLast()
                }
                continue
            }

            if let path = group.path {
                stackedPath.append(path)
            }

            for (key, value) in parseFileTree(group: group, project: project, stackedPath: stackedPath) {
                filePath[key] = value
            }

            if group.path != nil {
                _ = stackedPath.popLast()
            }
        }

        return filePath
    }

    // MARK: - Public

    func getConfig(configPath: String? = nil) -> Config? {
        guard let path = configPath ?? findPath(Constant.configFile) else {
            /// Not exist configuration file.
            /// Find to project file in current directory.
            #if swift(>=4.1)
            let projectList = (try? fileManager.contentsOfDirectory(atPath: basePath))?
                .compactMap { URL(string: $0) }
                .filter { $0.pathExtension == Constant.xcodeProjectExtension } ?? []
            #else
            let projectList = (try? fileManager.contentsOfDirectory(atPath: basePath))?
                .flatMap { URL(string: $0) }
                .filter { $0.pathExtension == Constant.xcodeProjectExtension } ?? []
            #endif

            guard let projectURL = projectList.first else {
                Logger.log(.error("Not found project file.", nil))
                return nil
            }
            guard projectList.count == 1 else {
                let projectMessage = projectList
                    .map { $0.lastPathComponent }
                    .joined(separator: ", ")

                Logger.log(.debug("Ambiguous project file: \(projectMessage)"))
                Logger.log(.error("Ambiguous project file.", nil))
                return nil
            }

            let projectName = projectURL.deletingPathExtension().lastPathComponent
            Logger.log(.info("Cannot find the Config file, so it uses `\(projectName)` project file."))
            return Config(
                target: [projectName],
                config: [projectName: ConfigInfo(project: projectName)]
            )
        }

        /// Exist configuration file.
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            return try YAMLDecoder().decode(Config.self, from: data)
        } catch {
            /// For Legacy.
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let info = try YAMLDecoder().decode(ConfigInfo.self, from: data)
                Logger.log(.warn("This config file is older.", nil))
                Logger.log(.warn("Please check the link below for the changes.", nil))
                Logger.log(.warn("https://github.com/kawoou/Deli/blob/master/README.md#getting-started", nil))
                Logger.log(.newLine)

                return Config(
                    target: [info.project],
                    config: [info.project: info]
                )
            } catch let error {
                Logger.log(.debug(error.localizedDescription))
                Logger.log(.error("Failed to load `\(Constant.configFile)` file.", nil))
                return nil
            }
        }
    }
    func getConfig(project: String, scheme: String?, output: String?) -> Config? {
        return Config(
            target: [project],
            config: [project: ConfigInfo(project: project, scheme: scheme, output: output)]
        )
    }

    func getOutputPath(info: ConfigInfo, fileName: String? = nil) -> String {
        let projectFile = convertToProjectFile(info.project)
        guard let projectPath = findPath(projectFile) else { return "" }
        guard let projectURL = URL(string: projectPath) else { return "" }

        let projectDirectory = projectURL.deletingLastPathComponent()
        let url = projectDirectory.appendingPathComponent(info.output ?? fileName ?? Constant.outputFile).standardized

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return url.appendingPathComponent(fileName ?? Constant.outputFile).standardized.path
        } else {
            return url.path
        }
    }
    func getClassName(info: ConfigInfo) -> String {
        let path = getOutputPath(info: info)
        
        let className: String = {
            if let name = info.className {
                return name
            }
            guard let url = URL(string: path) else { return Constant.className }
            guard let match = "(.+)\\.swift$".r?.findFirst(in: url.lastPathComponent) else { return Constant.className }
            return match.group(at: 1) ?? Constant.className
        }()
        
        let nameReplaceRegex = "(^[^a-zA-Z_]+|[^a-zA-Z0-9_]+)".r!
        let newClassName = nameReplaceRegex.replaceAll(in: className, with: "_")
        
        let first: String
        let other: String
        #if swift(>=4.0)
            first = newClassName.prefix(1).uppercased()
            other = String(newClassName.dropFirst())
        #else
            first = String(newClassName.characters.prefix(1)).capitalized
            other = String(newClassName.characters.dropFirst())
        #endif
        
        return first + other
    }
    func getSourceList(info: ConfigInfo) throws -> [String] {
        /// Check if project file exists.
        let projectFile = convertToProjectFile(info.project)
        guard let projectPath = findPath(projectFile) else {
            Logger.log(.error("Not found `\(projectFile)` file.", nil))
            throw ConfigurationError.projectNotFound
        }

        /// Load project file.
        guard let projectURL = URL(string: projectPath) else {
            Logger.log(.error("Cannnot open the project file: \(projectFile)", nil))
            throw ConfigurationError.projectCannotOpen
        }

        let projectDirectory = projectURL.deletingLastPathComponent()
        guard let project = try? XcodeProj(pathString: projectURL.absoluteString) else {
            Logger.log(.error("Cannnot open the project file: \(projectURL.lastPathComponent)", nil))
            throw ConfigurationError.projectCannotOpen
        }

        /// Find build reference
        let reference: BuildableReference?
        if let scheme = info.scheme {
            reference = findBuildReference(for: scheme, project: project)
        } else {
            reference = findBuildReference(project: project)
        }
        guard let buildReference = reference else {
            Logger.log(.error("Cannot load the build scheme: \(projectFile)", nil))
            throw ConfigurationError.schemeCannotLoad
        }

        /// Find native target
        let target: PBXNativeTarget? = try {
            if let target = project.pbxproj.objects.nativeTargets.first(where: { String($0.key.hashValue) == buildReference.id }) {
                return target.value
            }

            let targetList = project.pbxproj.objects.nativeTargets.filter { $0.value.name == buildReference.name }
            guard let target = targetList.first else {
                Logger.log(.error("Not found build target: \(projectFile)", nil))
                throw ConfigurationError.buildTargetNotFound
            }
            guard targetList.count == 1 else {
                Logger.log(.error("Ambiguous build target: \(projectFile)", nil))
                throw ConfigurationError.buildTargetAmbiguous
            }
            return target.value
        }()
        guard let nativeTarget = target else { return [] }

        /// Find root group
        guard let group = try? project.pbxproj.rootGroup() else { return [] }
        guard let rootGroup = group else { return [] }
        let fileDictionary = parseFileTree(group: rootGroup, project: project)
        let outputPath = getOutputPath(info: info)

        let fileReferenceList = project.pbxproj.objects.sourcesBuildPhases
            .first { nativeTarget.buildPhasesReferences.contains($0.key) }?
            .value
            .fileReferences ?? []

        let includeFiles = info.include.map { projectDirectory.appendingPathComponent($0).standardized.path }
        let excludeFiles = info.exclude.map { projectDirectory.appendingPathComponent($0).standardized.path }

        let sourceList: [String]
        #if swift(>=4.1)
        sourceList = fileReferenceList
            .compactMap { project.pbxproj.objects.buildFiles[$0]?.fileReference }
            .compactMap { fileDictionary[String($0.hashValue)] }
        #else
        sourceList = fileReferenceList
            .flatMap { project.pbxproj.objects.buildFiles[$0]?.fileReference }
            .flatMap { fileDictionary[String($0.hashValue)] }
        #endif

        let result = (sourceList + includeFiles)
            .map { projectDirectory.appendingPathComponent($0).standardized.path }
            .filter { $0.contains(".swift") }
            .filter { $0 != outputPath }
            .filter { excludeFiles.contains($0) == false }

        return result
            .filter { path in
                guard FileManager.default.fileExists(atPath: path) else {
                    Logger.log(.warn("The file `\(path)` couldn’t be opened because there is no such file.", nil))
                    return false
                }
                return true
            }
    }

    // MARK: - Lifecycle

    init() {}
}
