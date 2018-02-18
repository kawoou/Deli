//
//  main.swift
//  Deli
//

import Foundation
import Commandant
import Dispatch

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

DispatchQueue.global(qos: .default).async {
    let registry = CommandRegistry<CommandError>()
    registry.register(BuildCommand())
    registry.register(GenerateCommand())
    registry.register(ValidateCommand())
    registry.register(VersionCommand())
    registry.register(HelpCommand(registry: registry))

    registry.main(defaultVerb: "help") { error in
        Logger.log(.error(error.localizedDescription))
    }
}

dispatchMain()
