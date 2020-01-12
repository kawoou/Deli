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
        let baseURL = URL(fileURLWithPath: basePath)

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

    private func findBuildReference(forTarget targetName: String, project: XcodeProj) -> BuildableReference? {
        let targetList = project.pbxproj.nativeTargets
            .filter { $0.name == targetName }

        guard let target = targetList.first else {
            Logger.log(.error("Not found `\(targetName)` target.", nil))
            return nil
        }
        guard targetList.count == 1 else {
            let targetMessage = targetList
                .map { $0.uuid }
                .joined(separator: ", ")

            Logger.log(.debug("Ambiguous build target: \(targetMessage)"))
            Logger.log(.error("Ambiguous build target.", nil))
            return nil
        }

        return (
            id: target.uuid,
            name: target.name
        )
    }
    private func findBuildReference(forScheme schemeName: String, project: XcodeProj) -> BuildableReference? {
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
            id: String(buildAction.buildableReference.blueprintIdentifier),
            name: buildAction.buildableReference.buildableName
        )
    }
    private func findBuildReference(project: XcodeProj) -> BuildableReference? {
        let schemeList = project.sharedData?.schemes ?? []

        guard let scheme = schemeList.first else {
            guard let nativeTarget = project.pbxproj.nativeTargets.first else {
                Logger.log(.error("Not found build target.", nil))
                return nil
            }
            guard project.pbxproj.nativeTargets.count == 1 else {
                let targetMessage = project.pbxproj.nativeTargets
                    .map { $0.name }
                    .joined(separator: ", ")

                Logger.log(.debug("Ambiguous build target: \(targetMessage)"))
                Logger.log(.error("Ambiguous build target.", nil))
                return nil
            }
            return (
                id: nativeTarget.uuid,
                name: nativeTarget.name
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
            id: String(buildAction.buildableReference.blueprintIdentifier),
            name: buildAction.buildableReference.buildableName
        )
    }

    private func parseFileTree(group: PBXGroup, project: XcodeProj, stackedPath: [String] = []) -> [String: String] {
        var stackedPath = stackedPath
        var filePath = [String: String]()

        for element in group.children {
            guard let group = element as? PBXGroup else {
                if let path = element.path {
                    stackedPath.append(path)
                    filePath[element.uuid] = stackedPath.joined(separator: "/")
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
            let projectList = (try? fileManager.contentsOfDirectory(atPath: basePath))?
                .map { URL(fileURLWithPath: $0) }
                .filter { $0.pathExtension == Constant.xcodeProjectExtension } ?? []

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
    func getConfig(project: String, scheme: String?, target: String?, output: String?, properties: [String]) -> Config? {
        let info = ConfigInfo(
            project: project,
            scheme: scheme,
            target: target,
            output: output,
            properties: properties,
            dependencies: []
        )
        return Config(
            target: [info.project],
            config: [info.project: info]
        )
    }

    func getOutputPath(info: ConfigInfo, fileName: String? = nil) -> String {
        let projectFile = convertToProjectFile(info.project)
        guard let projectPath = findPath(projectFile) else { return "" }

        let projectURL = URL(fileURLWithPath: projectPath)
        let projectDirectory = projectURL.deletingLastPathComponent()
        let url = projectDirectory.appendingPathComponent(info.output ?? fileName ?? Constant.outputFile).standardized

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return url.appendingPathComponent(fileName ?? Constant.outputFile).standardized.path
        } else {
            return url.path
        }
    }
    func getResolvedOutputPath(info: ConfigInfo) -> String {
        let projectFile = convertToProjectFile(info.project)
        guard let projectPath = findPath(projectFile) else { return "" }

        let projectURL = URL(fileURLWithPath: projectPath)
        let projectDirectory = projectURL.deletingLastPathComponent()
        let url = projectDirectory.appendingPathComponent(info.resolve?.output ?? ResolveParser.Constant.resolveFile).standardized

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return url.appendingPathComponent(ResolveParser.Constant.resolveFile).standardized.path
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

            let url = URL(fileURLWithPath: path)
            guard let match = "(.+)\\.swift$".r?.findFirst(in: url.lastPathComponent) else { return Constant.className }
            return match.group(at: 1) ?? Constant.className
        }()
        
        let nameReplaceRegex = "(^[^a-zA-Z_]+|[^a-zA-Z0-9_]+)".r!
        let newClassName = nameReplaceRegex.replaceAll(in: className, with: "_")
        
        let first = newClassName.prefix(1).uppercased()
        let other = String(newClassName.dropFirst())
        
        return first + other
    }
    func getPropertyList(info: ConfigInfo, properties: [String]) -> [String] {
        let baseURL = URL(fileURLWithPath: basePath)

        /// Find properties recursive
        var propertyList: [String] = []
        func findProperties(url: URL, target: [String]) {
            var target = target

            let urlPath = url.standardized.path.replacingOccurrences(of: "//", with: "/")

            guard !target.isEmpty else {
                if self.fileManager.fileExists(atPath: urlPath) {
                    propertyList.append(urlPath)
                } else {
                    Logger.log(.warn("Not found the property file: \(urlPath)", nil))
                }
                return
            }

            guard let path = target.popLast() else { return }
            if path.contains("*") {
                let newPath = url.appendingPathComponent(path)
                    .standardized.path
                    .replacingOccurrences(of: "/", with: "\\/")

                let regex = newPath.split(separator: "*", omittingEmptySubsequences: false)
                    .map { "(\($0))" }
                    .joined(separator: "[^\\/]*").r!

                let contents = (try? self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
                for content in contents {
                    guard regex.findFirst(in: content.path) != nil else { continue }
                    findProperties(url: content, target: target)
                }
            } else {
                findProperties(url: url.appendingPathComponent(path), target: target)
            }
        }

        let properties = (info.properties + properties)
            .map { $0.split(separator: "/").map { String($0) } }

        for propertyPath in properties {
            findProperties(url: baseURL, target: propertyPath.reversed())
        }

        return propertyList
    }
    func getSourceList(info: ConfigInfo) throws -> [String] {
        /// Check if project file exists.
        let projectFile = convertToProjectFile(info.project)
        guard let projectPath = findPath(projectFile) else {
            Logger.log(.error("Not found `\(projectFile)` file.", nil))
            throw ConfigurationError.projectNotFound
        }

        /// Load project file.
        let projectURL = URL(fileURLWithPath: projectPath)
        let projectDirectory = projectURL.deletingLastPathComponent()
        guard let project = try? XcodeProj(pathString: projectURL.absoluteString) else {
            Logger.log(.error("Cannnot open the project file: \(projectURL.lastPathComponent)", nil))
            throw ConfigurationError.projectCannotOpen
        }

        /// Find build reference
        let reference: BuildableReference?
        if let target = info.target {
            reference = findBuildReference(forTarget: target, project: project)
        } else if let scheme = info.scheme {
            reference = findBuildReference(forScheme: scheme, project: project)
        } else {
            reference = findBuildReference(project: project)
        }
        guard let buildReference = reference else {
            Logger.log(.error("Cannot load the build scheme: \(projectFile)", nil))
            throw ConfigurationError.schemeCannotLoad
        }

        /// Find native target
        let target: PBXNativeTarget? = try {
            if let target = project.pbxproj.nativeTargets.first(where: { $0.uuid == buildReference.id }) {
                return target
            }

            let targetList = project.pbxproj.nativeTargets.filter { $0.name == buildReference.name }
            guard let target = targetList.first else {
                Logger.log(.error("Not found build target: \(projectFile)", nil))
                throw ConfigurationError.buildTargetNotFound
            }
            guard targetList.count == 1 else {
                Logger.log(.error("Ambiguous build target: \(projectFile)", nil))
                throw ConfigurationError.buildTargetAmbiguous
            }
            return target
        }()
        guard let nativeTarget = target else { return [] }

        /// Find root group
        guard let rootGroup = try? project.pbxproj.rootGroup() else { return [] }
        let fileDictionary = parseFileTree(group: rootGroup, project: project)
        let outputPath = getOutputPath(info: info)

        let fileList = project.pbxproj.sourcesBuildPhases
            .first { nativeTarget.buildPhases.map { $0.uuid }.contains($0.uuid) }?
            .files ?? []

        let includeFiles = info.include.map {
            projectDirectory.appendingPathComponent($0)
                .standardized.path
                .replacingOccurrences(of: "//", with: "/")
        }
        let excludeFiles = info.exclude.map {
            projectDirectory.appendingPathComponent($0)
                .standardized.path
                .replacingOccurrences(of: "//", with: "/")
        }

        let sourceList = fileList
            .compactMap { fileDictionary[$0.file?.uuid ?? ""] }

        let result = (sourceList + includeFiles)
            .map {
                projectDirectory.appendingPathComponent($0)
                    .standardized.path
                    .replacingOccurrences(of: "//", with: "/")
            }
            .filter { $0.contains(".swift") }
            .filter { $0 != outputPath }
            .filter { path in
                !excludeFiles.contains { path.hasPrefix($0) }
            }

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
