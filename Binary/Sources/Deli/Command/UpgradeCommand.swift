//
//  UpgradeCommand.swift
//  Deli
//

import Foundation
import Commandant

struct UpgradeCommand: CommandProtocol {
    let verb = "upgrade"
    let function = "Upgrade outdated."

    func run(_ options: UpgradeOptions) -> Result<(), CommandError> {
        Logger.isVerbose = options.isDebug || options.isVerbose
        Logger.isDebug = options.isDebug

        guard let latestVersion = VersionManager.shared.getLatestVersion() else {
            return .failure(.notFoundLatestVersion)
        }
        if latestVersion == "v\(Version.current.value)" {
            Logger.log(.info("No need to upgrade."))
            return .success(())
        }

        let script = """
        sleep 1
        OLD_PATH=`which deli`
        wget https://github.com/kawoou/Deli/releases/download/\(latestVersion)/portable_deli.zip -q -o /dev/null -O portable_deli.zip
        unzip -o -q portable_deli.zip
        sudo rm $OLD_PATH
        sudo cp ./deli $OLD_PATH
        echo "Upgrade complete to \(latestVersion)!"
        exit
        """

        let tempDirectory = NSTemporaryDirectory()
        let tempFile = "\(tempDirectory)/deli_upgrade.sh"
        do {
            try script.write(toFile: tempFile, atomically: false, encoding: .utf8)
        } catch {
            return .failure(.unknown)
        }

        let task = Process()
        task.launchPath = "/bin/bash"
        task.currentDirectoryPath = tempDirectory
        task.arguments = [tempFile]
        task.launch()
        exit(0)
    }
}

struct UpgradeOptions: OptionsProtocol {
    let isVerbose: Bool
    let isDebug: Bool

    static func create(isVerbose: Bool) -> (_ isDebug: Bool) -> UpgradeOptions {
        return { isDebug in
            self.init(
                isVerbose: isVerbose,
                isDebug: isDebug
            )
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<UpgradeOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(key: "verbose", defaultValue: false, usage: "turn on verbose logging")
            <*> mode <| Option(key: "debug", defaultValue: false, usage: "turn on debug logging")
    }
}
