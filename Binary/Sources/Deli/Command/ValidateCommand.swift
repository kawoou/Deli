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
        if options.isVerbose {
            Logger.isError = true
            Logger.isWarn = true
            Logger.isInfo = true
            Logger.isDebug = true
        }

        guard let configure = Configuration(path: options.configFile) else {
            return .failure(.failedToLoadConfigFile)
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
            NotImplementCorrector(parser: parser)
        ])
        let validator = Validator([
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
    let isVerbose: Bool

    static func create(configFile: String?) -> (_ isVerbose: Bool) -> ValidateOptions {
        return { isVerbose in
            self.init(configFile: configFile, isVerbose: isVerbose)
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<ValidateOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "config",
                defaultValue: nil,
                usage: "the path to Deli's configuration file"
            )
            <*> mode <| Option(
                key: "verbose",
                defaultValue: false,
                usage: "turn on verbose logging"
            )
    }
}
