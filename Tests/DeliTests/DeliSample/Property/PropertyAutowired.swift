//
//  PropertyAutowired.swift
//  DeliTests
//
//  Created by Kawoou on 27/11/2018.
//

import Deli

final class PropertyAutowired: Autowired {
    let network: NetworkProvider

    required init(_/*environment*/ network: NetworkProvider) {
        self.network = network
    }
}
