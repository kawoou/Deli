//
//  VersionCommand.swift
//  Deli
//

import Commandant

struct VersionCommand: CommandProtocol {
    let verb = "version"
    let function = "Display the current version of Deli"

    func run(_ options: NoOptions<CommandError>) -> Result<(), CommandError> {
        Logger.log(.info(Version.current.value))
        return .success(())
    }
}
