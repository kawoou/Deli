//
//  BuildProcess.swift
//  Deli
//

import Foundation

final class BuildProcess {

    // MARK: - Private

    private let configuration = Configuration()
    private let dependencyTree = DependencyTree()

    private let options: BuildProcessOptions
    private let properties: [String]

    private let configure: Config

    private var resolveFactoryMap = [String: String]()
    private var resolvedMap = [String: [ResolveData.Dependency]]()

    private func loadDependencies(
        _ info: ConfigInfo,
        resolveParser: ResolveParser,
        resolveFactories: inout [String: String]
    ) throws {
        for dependency in info.dependencies {
            switch dependency {
            case let .target(target):
                if let resolvedData = resolvedMap[target.target],
                    let factory = resolveFactoryMap[target.target],
                    let parentTarget = configure.config[target.target] {
                    try loadDependencies(
                        parentTarget,
                        resolveParser: resolveParser,
                        resolveFactories: &resolveFactories
                    )

                    resolveFactories[target.target] = factory
                    resolveParser.load(resolvedData, imports: target.imports, module: target.target)
                } else {
                    Logger.log(.error("Not found resolved target: \(target.target)", nil))
                    throw CommandError.notFoundResolvedTarget
                }
            case let .resolveFile(resolveFile):
                try resolveParser.load([resolveFile])
            }
        }
    }

    // MARK: - Public

    func processNext() throws -> BuildProcessResult? {
        guard let target = dependencyTree.pop() else { return nil }
        guard let info = configure.config[target] else { return nil }

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

        guard let sourceFiles = try? configuration.getSourceList(info: info) else {
            return BuildProcessResult(
                target: target,
                output: info.output ?? "\(className).swift",
                outputFile: outputFile,
                resolvedOutputFile: resolvedOutputFile,
                className: className,
                accessControl: info.accessControl,
                isGenerateResolveFile: info.resolve?.isGenerate ?? true,
                results: [],
                properties: [:],
                resolveFactories: [:],
                isSuccess: false
            )
        }
        if sourceFiles.count == 0 {
            Logger.log(.warn("No source files for processing.", nil))
        }

        if Logger.isVerbose {
            Logger.log(.debug("Source files:"))
            for source in sourceFiles {
                Logger.log(.debug(" - \(source)"))
            }
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
            DependencyParser(),
            PropertyValueParser(),
            ConfigPropertyParser()
        ])
        let corrector = Corrector([
            InheritanceCorrector(parser: parser),
            QualifierByCorrector(parser: parser, propertyParser: propertyParser),
            QualifierCorrector(parser: parser),
            ScopeCorrector(parser: parser),
            NotImplementCorrector(parser: parser, resolveParser: resolveParser),
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
            var resolveFactories = [String: String]()
            try loadDependencies(info, resolveParser: resolveParser, resolveFactories: &resolveFactories)

            let results = try validator.run(
                try corrector.run(
                    try resolveParser.run(
                        try parser.run(sourceFiles)
                    )
                )
            )

            resolveFactoryMap[target] = className
            resolvedMap[target] = {
                var newDict = [String: ResolveData.Dependency]()
                results.filter { !$0.isResolved }
                    .forEach { result in
                        let dependency = ResolveData.Dependency(result: result)

                        if var oldValue = newDict[dependency.type] {
                            oldValue.merging(dependency)
                            newDict[dependency.type] = oldValue
                        } else {
                            newDict[dependency.type] = dependency
                        }
                    }

                return Array(newDict.values).sorted { $0.type < $1.type }
            }()

            return BuildProcessResult(
                target: target,
                output: info.output ?? "\(className).swift",
                outputFile: outputFile,
                resolvedOutputFile: resolvedOutputFile,
                className: className,
                accessControl: info.accessControl,
                isGenerateResolveFile: info.resolve?.isGenerate ?? true,
                results: results,
                properties: propertyParser.properties,
                resolveFactories: resolveFactories,
                isSuccess: true
            )
        } catch let error {
            throw CommandError.runner(error)
        }
    }

    // MARK: - Lifecycle

    init(options: BuildProcessOptions, output: String?) throws {
        self.options = options
        self.properties = CommandLine.get(forKey: "property")

        if let project = options.project {
            guard let config = configuration.getConfig(
                project: project,
                scheme: options.scheme,
                target: options.target,
                output: output,
                properties: properties
            ) else {
                throw CommandError.failedToLoadConfigFile
            }
            self.configure = config
        } else {
            guard options.scheme == nil, output == nil else {
                throw CommandError.mustBeUsedWithProjectArguments
            }
            guard let config = configuration.getConfig(configPath: options.configFile) else {
                throw CommandError.failedToLoadConfigFile
            }
            self.configure = config
        }

        guard configure.target.count > 0 else {
            Logger.log(.warn("No targets are active.", nil))
            return
        }

        for target in configure.target {
            guard let info = configure.config[target] else {
                Logger.log(.warn("Target not found: `\(target)`", nil))
                continue
            }

            dependencyTree.append(target)
            for dependency in info.dependencies {
                guard case .target(let targetDependency) = dependency else { continue }
                dependencyTree.push(target, dependsOn: targetDependency.target)
            }
        }

        guard dependencyTree.validate() else {
            Logger.log(.error("The circular dependency between targets exists.", nil))
            throw CommandError.circularDependencyBetweenTargetsExists
        }
    }
}
