//
//  LazyAutowiredQualifier.swift
//  Deli
//
//  Created by Kawoou on 24/11/2018.
//

import Deli

final class LazyAutowiredQualifier: LazyAutowired {
    var testService: TestService?

    func inject(qualifierTest testService: TestService) {
        self.testService = testService
    }
    required init() {}
}
