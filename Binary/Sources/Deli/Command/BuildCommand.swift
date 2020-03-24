//
//  BuildCommand.swift
//  Deli
//

import Foundation
import Commandant

struct BuildCommand: CommandProtocol {
    let verb = "build"
    let function = "Build the Dependency Graph."

    func saveOutput(generator: Generator, outputFile: String) throws {
        let outputData = try generator.generate()

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: outputFile, isDirectory: &isDirectory), isDirectory.boolValue {
            Logger.log(.error("Cannot overwrite a directory with an output file: \(outputFile)", nil))
            throw CommandError.cannotOverwriteDirectory
        }
        try? FileManager.default.removeItem(atPath: outputFile)
        try outputData.write(toFile: outputFile, atomically: false, encoding: .utf8)
    }

    func run(_ options: BuildOptions) -> Result<(), CommandError> {
        do {
            LoggerProcess(options: options).process()

            let buildProcess = try BuildProcess(options: options, output: options.output)
            while let result = try buildProcess.processNext() {
                guard result.isSuccess else { continue }

                let generator = SourceGenerator(
                    className: result.className,
                    accessControl: result.accessControl,
                    results: result.results,
                    properties: result.properties
                )
                try saveOutput(generator: generator, outputFile: result.outputFile)

                if options.isResolveFile, result.isGenerateResolveFile {
                    let resolveGenerator = ResolveGenerator(
                        projectName: result.target,
                        fileName: result.output,
                        results: result.results,
                        properties: result.properties
                    )
                    try saveOutput(generator: resolveGenerator, outputFile: result.resolvedOutputFile)
                }

                Logger.log(.info("Generate file: \(result.outputFile)"))
                Logger.log(.newLine)
            }
        } catch let error {
            switch error {
            case let error as CommandError:
                return .failure(error)
            default:
                return .failure(.runner(error))
            }
        }

        return .success(())
    }
}

struct BuildOptions: OptionsProtocol, BuildProcessOptions, LoggerProcessOptions {
    let configFile: String?
    let project: String?
    let scheme: String?
    let target: String?
    let properties: String?
    let isVerbose: Bool
    let isDebug: Bool

    let output: String?
    let isResolveFile: Bool

    static func create(configFile: String?) ->
        (_ project: String?) ->
        (_ scheme: String?) ->
        (_ target: String?) ->
        (_ properties: String?) ->
        (_ isVerbose: Bool) ->
        (_ isDebug: Bool) ->
        (_ output: String?) ->
        (_ isResolveFile: Bool) -> BuildOptions {
        return { project in { scheme in { target in { properties in { isVerbose in { isDebug in { output in { isResolveFile in
            self.init(
                configFile: configFile,
                project: project,
                scheme: scheme,
                target: target,
                properties: properties,
                isVerbose: isVerbose,
                isDebug: isDebug,
                output: output,
                isResolveFile: isResolveFile
            )
        }}}}}}}}
    }

    static func evaluate(_ mode: CommandMode) -> Result<BuildOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "config",
                defaultValue: nil,
                usage: "the path of Deli's configuration file"
            )
            <*> mode <| Option(
                key: "project",
                defaultValue: nil,
                usage: "the path of project file"
            )
            <*> mode <| Option(
                key: "scheme",
                defaultValue: nil,
                usage: "using build scheme name"
            )
            <*> mode <| Option(
                key: "target",
                defaultValue: nil,
                usage: "using build target name"
            )
            <*> mode <| Option(
                key: "property",
                defaultValue: nil,
                usage: "the path of property file"
            )
            <*> mode <| Option(
                key: "verbose",
                defaultValue: false,
                usage: "turn on verbose logging"
            )
            <*> mode <| Option(
                key: "debug",
                defaultValue: false,
                usage: "turn on debug logging"
            )
            <*> mode <| Option(
                key: "output",
                defaultValue: nil,
                usage: "the path of output file"
            )
            <*> mode <| Option(
                key: "resolve-file",
                defaultValue: true,
                usage: "turn on generate resolved file"
            )
    }
}
