//
//  PropertyAutowiredFactory.swift
//  DeliTests
//
//  Created by Kawoou on 28/11/2018.
//

import Deli

struct PropertyAutowiredFactoryPayload: Payload {
    let a: Int
    let b: Bool

    init(with argument: (a: Int, b: Bool)) {
        self.a = argument.a
        self.b = argument.b
    }
}

final class PropertyAutowiredFactory: AutowiredFactory {
    let network: NetworkProvider
    
    required init(_/*environment*/ network: NetworkProvider, payload: PropertyAutowiredFactoryPayload) {
        self.network = network
    }
}
