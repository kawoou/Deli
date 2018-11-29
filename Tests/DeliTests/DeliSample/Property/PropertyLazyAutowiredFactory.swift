//
//  PropertyLazyAutowiredFactory.swift
//  DeliTests
//
//  Created by Kawoou on 28/11/2018.
//

import Deli

struct PropertyLazyAutowiredFactoryPayload: Payload {
    let a: Int
    let b: Bool

    init(with argument: (a: Int, b: Bool)) {
        self.a = argument.a
        self.b = argument.b
    }
}

final class PropertyLazyAutowiredFactory: LazyAutowiredFactory {
    var network: NetworkProvider!

    func inject(_/*environment*/ network: NetworkProvider) {
        self.network = network
    }

    required init(payload: PropertyLazyAutowiredFactoryPayload) {

    }
}
