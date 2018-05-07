//
//  BuildCommand.swift
//  Deli
//

import Foundation
import Commandant
import Result

struct BuildCommand: CommandProtocol {
    let verb = "build"
    let function = "Build the Dependency Graph."

    func run(_ options: BuildOptions) -> Result<(), CommandError> {
        Logger.isVerbose = options.isVerbose

        let configure: Configuration
        if let project = options.project {
            guard let config = Configuration(projectPath: project, scheme: options.scheme, output: options.output) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        } else {
            guard options.scheme == nil, options.output == nil else {
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
            let outputData = try SourceGenerator(results: results).generate()
            let url = URL(fileURLWithPath: configure.outputPath)
            try? FileManager.default.removeItem(at: url)
            try outputData.write(to: url, atomically: false, encoding: .utf8)

            Logger.log(.info("Generate file. \(configure.outputPath)"))
        } catch let error {
            return .failure(.runner(error))
        }

        return .success(())
    }
}

struct BuildOptions: OptionsProtocol {
    let configFile: String?
    let project: String?
    let scheme: String?
    let output: String?
    let isVerbose: Bool

    static func create(configFile: String?) -> (_ project: String?) -> (_ scheme: String?) -> (_ output: String?) -> (_ isVerbose: Bool) -> BuildOptions {
        return { project in { scheme in { output in { isVerbose in
            self.init(configFile: configFile, project: project, scheme: scheme, output: output, isVerbose: isVerbose)
        }}}}
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
                key: "output",
                defaultValue: nil,
                usage: "the path of output file"
            )
            <*> mode <| Option(
                key: "verbose",
                defaultValue: false,
                usage: "turn on verbose logging"
            )
    }
}
