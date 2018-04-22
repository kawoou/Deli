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
        
        let configure: Configuration
        if let project = options.project {
            guard let config = Configuration(projectPath: project, scheme: options.scheme, output: nil) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        } else {
            guard options.scheme == nil else {
                return .failure(.mustBeUsedWithProjectArguments)
            }
            guard let config = Configuration(path: options.configFile) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        }

        let sourceFiles = configure.getSourceList()
            .filter { $0.contains(".swift") }

        let parser = Parser([
            ComponentParser(),
            ConfigurationParser(),
            AutowiredParser(),
            LazyAutowiredParser(),
            InjectParser()
        ])
        let corrector = Corrector([
            QualifierCorrector(parser: parser),
            ScopeCorrector(parser: parser),
            NotImplementCorrector(parser: parser)
        ])
        let validator = Validator([
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
            
            if let path = options.outputFile {
                let url = URL(fileURLWithPath: path)
                try? FileManager.default.removeItem(at: url)
                try outputData.write(to: url, atomically: false, encoding: .utf8)
                
                Logger.log(.info("Generate file. \(path)"))
            } else {
                print(outputData)
            }
        } catch let error {
            return .failure(.runner(error))
        }

        return .success(())
    }
}

struct GenerateOptions: OptionsProtocol {
    let configFile: String?
    let isVerbose: Bool
    let project: String?
    let scheme: String?
    let outputFile: String?
    let type: String

    static func create(configFile: String?) -> (_ isVerbose: Bool) -> (_ project: String?) -> (_ scheme: String?) -> (_ outputFile: String?) -> (_ type: String) -> GenerateOptions {
        return { isVerbose in { project in { scheme in { outputFile in { type in
            self.init(configFile: configFile, isVerbose: isVerbose, project: project, scheme: scheme, outputFile: outputFile, type: type)
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
