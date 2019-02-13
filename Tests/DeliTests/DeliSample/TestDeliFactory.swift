//
//  TestDeliFactory.swift
//  DeliTests
//
//  Created by Kawoou on 12/02/2019.
//

import Deli

final class TestDeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        register(
            TestDeliObject.self,
            resolver: {
                return TestDeliObject(
                    a: context.getProperty("server.port", type: Int.self)!,
                    b: context.getProperty("server.url", type: String.self)!
                )
            },
            qualifier: "",
            scope: .always
        )
    }
}
