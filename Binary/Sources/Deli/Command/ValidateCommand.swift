//
//  ValidateCommand.swift
//  Deli
//

import Commandant

struct ValidateCommand: CommandProtocol {
    let verb = "validate"
    let function = "Validate the Dependency Graph."

    func run(_ options: ValidateOptions) -> Result<(), CommandError> {
        Logger.isVerbose = options.isDebug || options.isVerbose
        Logger.isDebug = options.isDebug

        let configuration = Configuration()
        let configure: Config
        let properties = CommandLine.get(forKey: "property")
        if let project = options.project {
            guard let config = configuration.getConfig(
                project: project,
                scheme: options.scheme,
                target: options.target,
                output: nil,
                properties: properties
            ) else {
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
            guard let sourceFiles = try? configuration.getSourceList(info: info) else { continue }
            if sourceFiles.count == 0 {
                Logger.log(.warn("No source files for processing.", nil))
            }
            Logger.log(.debug("Source files:"))
            for source in sourceFiles {
                Logger.log(.debug(" - \(source)"))
            }

            let propertyParser = PropertyParser()
            let resolveParser = ResolveParser()
            let parser = Parser([
                ComponentParser(),
                ConfigurationParser(),
                AutowiredParser(),
                LazyAutowiredParser(),
                AutowiredFactoryParser(),
                LazyAutowiredFactoryParser(),
                InjectParser(),
                InjectPropertyParser(),
                ConfigPropertyParser()
            ])
            let corrector = Corrector([
                QualifierByCorrector(parser: parser, propertyParser: propertyParser),
                QualifierCorrector(parser: parser),
                ScopeCorrector(parser: parser),
                NotImplementCorrector(parser: parser),
                ConfigPropertyCorrector(parser: parser, propertyParser: propertyParser)
            ])
            let validator = Validator([
                FactoryReferenceValidator(parser: parser),
                CircularDependencyValidator(parser: parser),
                InjectPropertyValidator(parser: parser, propertyParser: propertyParser)
            ])

            let propertyFiles = configuration.getPropertyList(info: info, properties: properties)
            propertyParser.load(propertyFiles)

            do {
                try resolveParser.load(info.dependencies)

                _ = try validator.run(
                    try corrector.run(
                        try resolveParser.run(
                            try parser.run(sourceFiles)
                        )
                    )
                )

                Logger.log(.info("Validate success."))
            } catch let error {
                return .failure(.runner(error))
            }
        }
        return .success(())
    }
}

struct ValidateOptions: OptionsProtocol {
    let configFile: String?
    let project: String?
    let scheme: String?
    let target: String?
    let properties: String?
    let isVerbose: Bool
    let isDebug: Bool

    static func create(configFile: String?) -> (_ project: String?) -> (_ scheme: String?) -> (_ target: String?) -> (_ properties: String?) -> (_ isVerbose: Bool) -> (_ isDebug: Bool) -> ValidateOptions {
        return { project in { scheme in { target in { properties in { isVerbose in { isDebug in
            self.init(
                configFile: configFile,
                project: project,
                scheme: scheme,
                target: target,
                properties: properties,
                isVerbose: isVerbose,
                isDebug: isDebug
            )
        }}}}}}
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
    }
}
