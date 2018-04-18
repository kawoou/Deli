//
//  main.swift
//  Deli
//

import Foundation
import Commandant
import Dispatch
import Darwin

DispatchQueue.global(qos: .default).async {
    if let latestVersion = VersionManager.shared.getLatestVersion(timeout: 3000), latestVersion != "v\(Version.current.value)" {
        Logger.log(
            .info(
                """
                Deli \(latestVersion) is available.
                To update use: `deli upgrade`

                """
            ),
            color: .green
        )
    }

    let registry = CommandRegistry<CommandError>()
    registry.register(BuildCommand())
    registry.register(GenerateCommand())
    registry.register(ValidateCommand())
    registry.register(VersionCommand())
    registry.register(UpgradeCommand())
    registry.register(HelpCommand(registry: registry))

    registry.main(defaultVerb: "help") { error in
        Logger.log(.error(error.localizedDescription))
    }
}

dispatchMain()
