//
//  UpgradeCommand.swift
//  Deli
//

import Foundation
import Commandant
import Result

struct UpgradeCommand: CommandProtocol {
    let verb = "upgrade"
    let function = "Upgrade outdated."

    func run(_ options: UpgradeOptions) -> Result<(), CommandError> {
        Logger.isVerbose = options.isVerbose

        guard let latestVersion = VersionManager.shared.getLatestVersion() else {
            return .failure(.notFoundLatestVersion)
        }
        guard latestVersion != "v\(Version.current.value)" else {
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

    static func create(isVerbose: Bool) -> UpgradeOptions {
        return self.init(isVerbose: isVerbose)
    }

    static func evaluate(_ mode: CommandMode) -> Result<UpgradeOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "verbose",
                defaultValue: false,
                usage: "turn on verbose logging"
            )
    }
}
