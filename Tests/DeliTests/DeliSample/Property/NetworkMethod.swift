//
//  NetworkMethod.swift
//  DeliTests
//
//  Created by Kawoou on 27/11/2018.
//

import Deli

protocol NetworkMethod {
    var qualifier: String? { get }
}

struct PostMethod: NetworkMethod, Component {
    var qualifier: String? = "post"
}
struct GetMethod: NetworkMethod, Component {
    var qualifier: String? = "get"
}
struct PutMethod: NetworkMethod, Component {
    var qualifier: String? = "put"
}
struct DeleteMethod: NetworkMethod, Component {
    var qualifier: String? = "delete"
}
