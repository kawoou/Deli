//
//  Configuration.swift
//  Deli
//

import Foundation
import xcproj
import Yams

final class Configuration {

    // MARK: - Constant

    private struct Constant {
        static let configFile = "deli.yml"
        static let outputFile = "DeliFactory.swift"

        static let xcodeProjectExtension = "xcodeproj"
        static let xcodeSchemeExtension = "xcscheme"
    }

    // MARK: - Property

    let outputPath: String

    // MARK: - Private

    private let fileManager = FileManager.default

    private let projectPath: String

    private let project: XcodeProj
    private let target: PBXNativeTarget

    private var filePath = [String: String]()

    // MARK: - Public

    func getSourceList() -> [String] {
        #if swift(>=4.1)
        return project.pbxproj.objects.sourcesBuildPhases
            .first { [weak self] (key, value) in
                guard let ss = self else { return false }
                return ss.target.buildPhases.contains(key)
            }?
            .value
            .files
            .compactMap { [weak self] fileKey -> String? in
                guard let ss = self else { return nil }
                return ss.project.pbxproj.objects.buildFiles[fileKey]?.fileRef
            }
            .compactMap { [weak self] refKey -> String? in
                guard let ss = self else { return nil }
                guard let path = ss.filePath[refKey] else { return nil }
                return "\(ss.projectPath)/\(path)"
            }
            .filter { [weak self] path in
                guard let ss = self else { return false }
                return path != ss.outputPath
            }
            .filter { path in
                guard FileManager.default.fileExists(atPath: path) else {
                    Logger.log(.warn("The file `\(path)` couldn’t be opened because there is no such file.", nil))
                    return false
                }
                return true
            } ?? []
        #else
        return project.pbxproj.objects.sourcesBuildPhases
            .first { [weak self] (key, value) in
                guard let ss = self else { return false }
                return ss.target.buildPhases.contains(key)
            }?
            .value
            .files
            .flatMap { [weak self] fileKey in
                guard let ss = self else { return nil }
                return ss.project.pbxproj.objects.buildFiles[fileKey]?.fileRef
            }
            .flatMap { [weak self] refKey in
                guard let ss = self else { return nil }
                guard let path = ss.filePath[refKey] else { return nil }
                return "\(ss.projectPath)/\(path)"
            }
            .filter { [weak self] path in
                guard let ss = self else { return false }
                return path != ss.outputPath
            }
            .filter { [weak self] path in
                guard FileManager.default.fileExists(atPath: path) else {
                    Logger.log(.warn("The file `\(path)` couldn’t be opened because there is no such file."))
                    return false
                }
                return true
            } ?? []
        #endif
    }

    // MARK: - Private

    private var stackedPath: [String] = []
    private func parseFileTree(group: PBXGroup) {
        for groupKey in group.children {
            guard let group = project.pbxproj.objects.groups[groupKey] else {
                if let path = project.pbxproj.objects.fileReferences[groupKey]?.path {
                    stackedPath.append(path)
                    filePath[groupKey] = stackedPath.joined(separator: "/")
                    _ = stackedPath.popLast()
                }
                continue
            }

            if let path = group.path {
                stackedPath.append(path)
            }

            parseFileTree(group: group)

            if group.path != nil {
                _ = stackedPath.popLast()
            }
        }
    }

    private static func loadConfig(_ path: String?) -> (Config, String)? {
        guard let configPath = path ?? findURL(Constant.configFile), let url = URL(string: configPath) else {
            /// Not exist configuration file.
            /// Find to project file in current directory.
            let currentDirectory = FileManager.default.currentDirectoryPath

            #if swift(>=4.1)
            let projectList = (try? FileManager.default.contentsOfDirectory(atPath: currentDirectory))?
                .compactMap { URL(string: $0) }
                .filter { $0.pathExtension == Constant.xcodeProjectExtension } ?? []
            #else
            let projectList = (try? FileManager.default.contentsOfDirectory(atPath: currentDirectory))?
                .flatMap { URL(string: $0) }
                .filter { $0.pathExtension == Constant.xcodeProjectExtension } ?? []
            #endif

            guard projectList.count > 0 else {
                Logger.log(.error("Not found project file.", nil))
                return nil
            }
            guard projectList.count == 1 else {
                Logger.log(.debug("Ambiguous project file: \(projectList.map { $0.lastPathComponent }.joined(separator: ", "))"))
                Logger.log(.error("Ambiguous project file.", nil))
                return nil
            }
            return (Config(project: projectList[0].lastPathComponent), currentDirectory)
        }

        /// Exist configuration file.
        do {
            let data = try String(contentsOfFile: configPath, encoding: .utf8)
            return (try YAMLDecoder().decode(Config.self, from: data), url.deletingLastPathComponent().path)
        } catch let error {
            Logger.log(.debug(error.localizedDescription))
            Logger.log(.error("Failed to load `\(Constant.configFile)` file.", nil))
            return nil
        }
    }
    private static func findURL(_ fileName: String) -> String? {
        #if swift(>=4.1)
        return (try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath))?
            .compactMap { URL(string: $0) }
            .filter { $0.lastPathComponent == fileName }
            .first?
            .path
        #else
        return (try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath))?
            .flatMap { URL(string: $0) }
            .filter { $0.lastPathComponent == fileName }
            .first?
            .path
        #endif
    }
    private static func findBuildReference(project: XcodeProj, schemeName: String?) -> String? {
        let schemeList: [XCScheme] = {
            if let schemeName = schemeName {
                return project.sharedData?.schemes
                    .filter { $0.name == schemeName }
            } else {
                return project.sharedData?.schemes
            }
        }() ?? []

        if schemeList.count == 0 {
            guard schemeName == nil else {
                Logger.log(.error("Build scheme `\(schemeName!)` is not shared.", nil))
                return nil
            }
            guard project.pbxproj.objects.nativeTargets.count > 0 else {
                Logger.log(.error("Not found build target.", nil))
                return nil
            }
            guard project.pbxproj.objects.nativeTargets.count == 1 else {
                Logger.log(.debug("Ambiguous build target: \(project.pbxproj.objects.nativeTargets.keys.joined(separator: ", "))"))
                Logger.log(.error("Ambiguous build target.", nil))
                return nil
            }
            return project.pbxproj.objects.nativeTargets.keys.first
        }

        guard schemeList.count == 1 else {
            Logger.log(.debug("Ambiguous shared build scheme: \(schemeList.map { $0.name }.joined(separator: ", "))"))
            Logger.log(.error("Ambiguous shared build scheme.", nil))
            return nil
        }

        let scheme = schemeList[0]
        return scheme.buildAction?.buildActionEntries.first?.buildableReference.blueprintIdentifier
    }

    // MARK: - Lifecycle
    
    private init?(config: Config, basePath: String) {
        let projectFile: String = {
            if config.project.hasSuffix(Constant.xcodeProjectExtension) {
                return config.project
            } else {
                return "\(config.project).\(Constant.xcodeProjectExtension)"
            }
        }()
        guard let projectURL = URL(string: "\(basePath)/\(projectFile)") else {
            Logger.log(.error("Cannnot open the project file: \(projectFile)", nil))
            return nil
        }
        
        guard let project = try? XcodeProj(pathString: projectURL.path) else {
            Logger.log(.error("Cannnot open the project file: \(projectURL.lastPathComponent)", nil))
            return nil
        }
        guard let buildReference = Configuration.findBuildReference(project: project, schemeName: config.scheme) else {
            Logger.log(.error("Cannot load the build scheme: \(projectURL.lastPathComponent)", nil))
            return nil
        }
        guard let nativeTarget = project.pbxproj.objects.nativeTargets.first(where: { $0.key == buildReference }) else {
            Logger.log(.error("Cannot load the build scheme: \(projectURL.lastPathComponent)", nil))
            return nil
        }
        
        let outputPath: String = {
            let path = "\(basePath)/\(config.output ?? Constant.outputFile)"
            
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue {
                return "\(path)/\(Constant.outputFile)"
            } else {
                return path
            }
        }()
        
        self.projectPath = basePath
        self.project = project
        self.target = nativeTarget.value
        self.outputPath = outputPath
        
        parseFileTree(group: self.project.pbxproj.rootGroup)
    }
    
    convenience init?(projectPath: String, scheme: String?, output: String?) {
        guard let url = URL(string: projectPath) else { return nil }
        let config = Config(project: url.lastPathComponent, scheme: scheme, output: output)
        let basePath = url.deletingLastPathComponent().path
        
        self.init(config: config, basePath: basePath)
    }
    convenience init?(path: String?) {
        guard let (config, basePath) = Configuration.loadConfig(path) else { return nil }
        
        self.init(config: config, basePath: basePath)
    }
}
