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
    let isVerbose: Bool

    static func create(configFile: String?) -> (_ isVerbose: Bool) -> BuildOptions {
        return { isVerbose in
            self.init(configFile: configFile, isVerbose: isVerbose)
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<BuildOptions, CommandantError<CommandError>> {
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
    }
}
