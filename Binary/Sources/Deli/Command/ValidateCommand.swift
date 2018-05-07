//
//  ValidateCommand.swift
//  Deli
//

import Commandant
import Result

struct ValidateCommand: CommandProtocol {
    let verb = "validate"
    let function = "Validate the Dependency Graph."

    func run(_ options: ValidateOptions) -> Result<(), CommandError> {
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
            _ = try validator.run(
                try corrector.run(
                    try parser.run(sourceFiles)
                )
            )

            Logger.log(.info("Validate success."))
        } catch let error {
            return .failure(.runner(error))
        }

        return .success(())
    }
}

struct ValidateOptions: OptionsProtocol {
    let configFile: String?
    let project: String?
    let scheme: String?
    let isVerbose: Bool

    static func create(configFile: String?) -> (_ project: String?) -> (_ scheme: String?) -> (_ isVerbose: Bool) -> ValidateOptions {
        return { project in { scheme in { isVerbose in
            self.init(configFile: configFile, project: project, scheme: scheme, isVerbose: isVerbose)
        }}}
    }

    static func evaluate(_ mode: CommandMode) -> Result<ValidateOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "config",
                defaultValue: nil,
                usage: "the path to Deli's configuration file"
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
                key: "verbose",
                defaultValue: false,
                usage: "turn on verbose logging"
            )
    }
}
