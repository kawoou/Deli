//
//  StructWithLazyAutowired.swift
//  DeliTests
//
//  Created by Kawoou on 23/11/2018.
//

import Deli

struct StructWithLazyAutowired: LazyAutowired {
    mutating func inject(_ friendService: FriendService) {

    }
}
