//
//  InjectPropertyTest.swift
//  DeliTests
//
//  Created by Kawoou on 28/11/2018.
//

import Deli

final class InjectPropertyTest: Component {

    let url = InjectProperty("server.url")
    let method = InjectProperty("server.method")
    let test = AppContext.shared.getProperty("server.test")

    required init() {}
}
