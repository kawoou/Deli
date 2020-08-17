//
//  BuildProcessOptions.swift
//  Deli
//

protocol BuildProcessOptions {
    var configFile: String? { get }
    var project: String? { get }
    var scheme: String? { get }
    var target: String? { get }
    var properties: String? { get }
}
