//
//  PropertyLazyAutowired.swift
//  DeliTests
//
//  Created by Kawoou on 28/11/2018.
//

import Deli

final class PropertyLazyAutowired: LazyAutowired {
    var network: NetworkProvider!

    func inject(_/*environment*/ network: NetworkProvider) {
        self.network = network
    }

    required init() {}
}
