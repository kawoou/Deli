//
//  GenerateCommand.swift
//  Deli
//

import Foundation
import Commandant
import Result

struct GenerateCommand: CommandProtocol {
    let verb = "generate"
    let function = "Generate the Dependency Graph."

    func run(_ options: GenerateOptions) -> Result<(), CommandError> {
        Logger.isVerbose = options.isVerbose

        let configuration = Configuration()
        let configure: Config
        if let project = options.project {
            guard let config = configuration.getConfig(project: project, scheme: options.scheme, output: nil) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        } else {
            guard options.scheme == nil else {
                return .failure(.mustBeUsedWithProjectArguments)
            }
            guard let config = configuration.getConfig(configPath: options.configFile) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        }

        guard configure.target.count > 0 else {
            Logger.log(.warn("No targets are active.", nil))
            return .success(())
        }
        for target in configure.target {
            guard let info = configure.config[target] else {
                Logger.log(.warn("Target not found: `\(target)`", nil))
                continue
            }

            Logger.log(.info("Set Target `\(target)`"))
            let sourceFiles = configuration.getSourceList(info: info)
            if sourceFiles.count == 0 {
                Logger.log(.warn("Empty source files.", nil))
            }
            Logger.log(.debug("Source files:"))
            for source in sourceFiles {
                Logger.log(.debug(" - \(source)"))
            }

            let parser = Parser([
                ComponentParser(),
                ConfigurationParser(),
                AutowiredParser(),
                LazyAutowiredParser(),
                AutowiredFactoryParser(),
                LazyAutowiredFactoryParser(),
                InjectParser()
            ])
            let corrector = Corrector([
                QualifierCorrector(parser: parser),
                ScopeCorrector(parser: parser),
                NotImplementCorrector(parser: parser)
            ])
            let validator = Validator([
                FactoryReferenceValidator(parser: parser),
                CircularDependencyValidator(parser: parser)
            ])

            do {
                let results = try validator.run(
                    try corrector.run(
                        try parser.run(sourceFiles)
                    )
                )

                let outputData: String
                switch options.type {
                case "graph", "html":
                    outputData = try GraphGenerator(results: results).generate()
                case "code", "swift":
                    outputData = try SourceGenerator(results: results).generate()
                case "raw":
                    outputData = try RawGenerator(results: results).generate()
                default:
                    throw CommandError.unacceptableType
                }

                if let path = options.output {
                    let url = URL(fileURLWithPath: path)
                    try? FileManager.default.removeItem(at: url)
                    try outputData.write(to: url, atomically: false, encoding: .utf8)

                    Logger.log(.info("Generate file: \(path)"))
                } else {
                    print(outputData)
                }
            } catch let error {
                return .failure(.runner(error))
            }
        }
        return .success(())
    }
}

struct GenerateOptions: OptionsProtocol {
    let configFile: String?
    let isVerbose: Bool
    let project: String?
    let scheme: String?
    let output: String?
    let type: String

    static func create(configFile: String?) -> (_ isVerbose: Bool) -> (_ project: String?) -> (_ scheme: String?) -> (_ output: String?) -> (_ type: String) -> GenerateOptions {
        return { isVerbose in { project in { scheme in { output in { type in
            self.init(configFile: configFile, isVerbose: isVerbose, project: project, scheme: scheme, output: output, type: type)
        }}}}}
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
