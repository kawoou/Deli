//
//  ServerConfig.swift
//  DeliTests
//
//  Created by Kawoou on 28/11/2018.
//

import Deli

struct ServerConfig: ConfigProperty {
    let target: String = "server"

    let method: String
    let url: String
    let port: Int

    init(method: String, url: String, port: String) {
        self.method = method
        self.url = url
        self.port = Int(port) ?? 0
    }
}
