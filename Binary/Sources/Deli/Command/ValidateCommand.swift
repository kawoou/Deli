//
//  ValidateCommand.swift
//  Deli
//

import Commandant

struct ValidateCommand: CommandProtocol {
    let verb = "validate"
    let function = "Validate the Dependency Graph."

    func run(_ options: ValidateOptions) -> Result<(), CommandError> {
        do {
            LoggerProcess(options: options).process()

            let buildProcess = try BuildProcess(options: options, output: nil)
            while let result = try buildProcess.processNext() {
                guard result.isSuccess else { continue }

                Logger.log(.info("Validate success."))
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

struct ValidateOptions: OptionsProtocol, BuildProcessOptions, LoggerProcessOptions {
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
