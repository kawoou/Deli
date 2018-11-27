//
//  NetworkProvider.swift
//  DeliTests
//
//  Created by Kawoou on 27/11/2018.
//

import Deli

protocol NetworkProvider {
    var qualifier: String? { get }
}

class TestNetworkProvider: NetworkProvider, Component {
    var qualifier: String? = "test"
}
class DevNetworkProvider: NetworkProvider, Component {
    var qualifier: String? = "dev"
}
class ProdNetworkProvider: NetworkProvider, Component {
    var qualifier: String? = "prod"
}
