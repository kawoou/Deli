//
//  BuildCommand.swift
//  Deli
//

import Foundation
import Commandant

struct BuildCommand: CommandProtocol {
    let verb = "build"
    let function = "Build the Dependency Graph."

    func saveOutput(generator: Generator, outputFile: String) throws {
        let outputData = try generator.generate()
        let url = URL(fileURLWithPath: outputFile)

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: outputFile, isDirectory: &isDirectory), isDirectory.boolValue {
            Logger.log(.error("Cannot overwrite a directory with an output file: \(outputFile)", nil))
            throw CommandError.cannotOverwriteDirectory
        }
        try? FileManager.default.removeItem(at: url)
        try outputData.write(to: url, atomically: false, encoding: .utf8)
    }

    func run(_ options: BuildOptions) -> Result<(), CommandError> {
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
                output: options.output,
                properties: properties
            ) else {
                return .failure(.failedToLoadConfigFile)
            }
            configure = config
        } else {
            guard options.scheme == nil, options.output == nil else {
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
            let outputFile: String
            let className: String
            let resolvedOutputFile = configuration.getResolvedOutputPath(info: info)
            if info.className != nil {
                className = configuration.getClassName(info: info)
                outputFile = configuration.getOutputPath(info: info, fileName: "\(className).swift")
            } else {
                outputFile = configuration.getOutputPath(info: info)
                className = configuration.getClassName(info: info)
            }

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

                let results = try validator.run(
                    try corrector.run(
                        try resolveParser.run(
                            try parser.run(sourceFiles)
                        )
                    )
                )
                let generator = SourceGenerator(
                    className: className,
                    accessControl: info.accessControl,
                    results: results,
                    properties: propertyParser.properties
                )
                try saveOutput(generator: generator, outputFile: outputFile)

                if options.isResolveFile, (info.resolve?.isGenerate ?? true) {
                    let resolveGenerator = ResolveGenerator(
                        projectName: target,
                        fileName: info.output ?? "\(className).swift",
                        results: results,
                        properties: propertyParser.properties
                    )
                    try saveOutput(generator: resolveGenerator, outputFile: resolvedOutputFile)
                }

                Logger.log(.info("Generate file: \(outputFile)"))
            } catch let error {
                return .failure(.runner(error))
            }

            Logger.log(.newLine)
        }
        return .success(())
    }
}

struct BuildOptions: OptionsProtocol {
    let configFile: String?
    let project: String?
    let scheme: String?
    let target: String?
    let output: String?
    let properties: String?
    let isResolveFile: Bool
    let isVerbose: Bool
    let isDebug: Bool

    static func create(configFile: String?) -> (_ project: String?) -> (_ scheme: String?) -> (_ target: String?) -> (_ output: String?) -> (_ properties: String?) -> (_ isResolveFile: Bool) -> (_ isVerbose: Bool) -> (_ isDebug: Bool) -> BuildOptions {
        return { project in { scheme in { target in { output in { properties in { isResolveFile in { isVerbose in { isDebug in
            self.init(
                configFile: configFile,
                project: project,
                scheme: scheme,
                target: target,
                output: output,
                properties: properties,
                isResolveFile: isResolveFile,
                isVerbose: isVerbose,
                isDebug: isDebug
            )
        }}}}}}}}
    }

    static func evaluate(_ mode: CommandMode) -> Result<BuildOptions, CommandantError<CommandError>> {
        return create
            <*> mode <| Option(
                key: "config",
                defaultValue: nil,
                usage: "the path of Deli's configuration file"
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
                key: "output",
                defaultValue: nil,
                usage: "the path of output file"
            )
            <*> mode <| Option(
                key: "property",
                defaultValue: nil,
                usage: "the path of property file"
            )
            <*> mode <| Option(
                key: "resolve-file",
                defaultValue: true,
                usage: "turn on generate resolved file"
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
