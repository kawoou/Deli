//
//  PropertyWrapperTest1.swift
//  Deli
//
//  Created by Kawoou on 2020/03/15.
//

import Deli

class PropertyWrapperTest1: Autowired {
    var scope: Scope {
        return .prototype
    }

    var testCount: Int = 0

    let accountService: AccountService
    let friendService: FriendService

    func test() {
        testCount += 1
    }

    required init(google accountService: AccountService, _ friendService: FriendService) {
        self.accountService = accountService
        self.friendService = friendService
    }
}
