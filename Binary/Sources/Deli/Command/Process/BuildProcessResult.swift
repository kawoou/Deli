//
//  BuildProcessResult.swift
//  Deli
//

import Foundation

struct BuildProcessResult {
    let target: String
    let output: String
    let outputFile: String
    let resolvedOutputFile: String
    let className: String
    let accessControl: String?
    let isGenerateResolveFile: Bool
    let results: [Results]
    let properties: [String: Any]
    let isSuccess: Bool
}
