//
//  StructWithAutowired.swift
//  DeliTests
//
//  Created by Kawoou on 23/11/2018.
//

import Deli

struct StructWithAutowired: Autowired {
    let friendService: FriendService

    init(_ friendService: FriendService) {
        self.friendService = friendService
    }
}
