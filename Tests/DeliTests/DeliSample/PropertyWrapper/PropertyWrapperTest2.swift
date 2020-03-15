//
//  PropertyWrapperTest2.swift
//  DeliTests
//
//  Created by Kawoou on 2020/03/15.
//

import Deli

protocol PropertyWrapperTest2 {}

class PropertyWrapperTest3: PropertyWrapperTest2, Component {
    var scope: Scope {
        return .prototype
    }

    required init() {}
}

class PropertyWrapperTest4: PropertyWrapperTest2, Component {
    var scope: Scope {
        return .prototype
    }

    required init() {}
}
