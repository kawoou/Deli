//
//  LoggerProces.swift
//  deli
//
//  Created by 안정원 on 2020/03/24.
//

import Foundation

final class LoggerProcess {

    // MARK: - Private

    private let options: LoggerProcessOptions

    // MARK: - Public

    func process() {
        Logger.isVerbose = options.isDebug || options.isVerbose
        Logger.isDebug = options.isDebug
    }

    // MARK: - Lifecycle

    init(options: LoggerProcessOptions) {
        self.options = options
    }
}
