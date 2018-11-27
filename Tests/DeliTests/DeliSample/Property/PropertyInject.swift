//
//  PropertyInject.swift
//  DeliTests
//
//  Created by Kawoou on 27/11/2018.
//

import Deli

final class PropertyInject: Component {
    var method = Inject(NetworkMethod.self, qualifierBy: "server.method")
}
