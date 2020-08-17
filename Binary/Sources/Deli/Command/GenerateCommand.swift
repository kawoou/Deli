//
//  GenerateCommand.swift
//  Deli
//

import Foundation
import Commandant

struct GenerateCommand: CommandProtocol {
    let verb = "generate"
    let function = "Generate the Dependency Graph."

    func saveOutput(generator: Generator, outputFile: String) throws {
        let outputData = try generator.generate()
        let url = URL(fileURLWithPath: outputFile)

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: outputFile, isDirectory: &isDirectory), isDirectory.boolValue {
            Logger.log(.error("Cannot overwrite a directory with an output file: \(outputFile)", nil))
            throw CommandError.cannotOverwriteDirectory
        }
        try? FileManager.default.removeItem(at: url)
        try outputData.write(to: url, atomically: false, encoding: .utf8)
    }

    func run(_ options: GenerateOptions) -> Result<(), CommandError> {
        do {
            LoggerProcess(options: options).process()

            let buildProcess = try BuildProcess(options: options, output: options.output)
            while let result = try buildProcess.processNext() {
                guard result.isSuccess else { continue }
                
                let generator: Generator = try {
                    switch options.type {
                    case "graph", "html":
                        return GraphGenerator(
                            results: result.results,
                            properties: result.properties
                        )
                    case "code", "swift":
                        return SourceGenerator(
                            className: result.className,
                            accessControl: result.accessControl,
                            results: result.results,
                            properties: result.properties,
                            resolveFactories: result.resolveFactories
                        )
                    case "raw", "text":
                        return RawGenerator(
                            results: result.results,
                            properties: result.properties
                        )
                    default:
                        throw CommandError.unacceptableType
                    }
                }()

                if let path = options.output {
                    try saveOutput(generator: generator, outputFile: path)
                    Logger.log(.info("Generate file: \(path)"))
                    Logger.log(.newLine)
                } else {
                    print()
                    print(try generator.generate())
                }
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

struct GenerateOptions: OptionsProtocol, BuildProcessOptions, LoggerProcessOptions {
    let configFile: String?
    let isVerbose: Bool
    let isDebug: Bool
    let project: String?
    let scheme: String?
    let target: String?
    let properties: String?

    let output: String?
    let type: String

    static func create(configFile: String?) ->
        (_ isVerbose: Bool) ->
        (_ isDebug: Bool) ->
        (_ project: String?) ->
        (_ scheme: String?) ->
        (_ target: String?) ->
        (_ properties: String?) ->
        (_ output: String?) ->
        (_ type: String) -> GenerateOptions {
        return { isVerbose in { isDebug in { project in { scheme in { target in { properties in { output in { type in
            self.init(
                configFile: configFile,
                isVerbose: isVerbose,
                isDebug: isDebug,
                project: project,
                scheme: scheme,
                target: target,
                properties: properties,
                output: output,
                type: type
            )
        }}}}}}}}
    }

    static func evaluate(_ mode: CommandMode) -> Result<GenerateOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "config",
                defaultValue: nil,
                usage: "the path of Deli's configuration file"
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
                key: "output",
                defaultValue: nil,
                usage: "the path of output file"
            )
            <*> mode <| Option(
                key: "type",
                defaultValue: "code",
                usage: "is output type (graph, code, raw)"
            )
    }
}
