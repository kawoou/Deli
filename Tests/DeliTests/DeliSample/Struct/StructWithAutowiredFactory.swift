//
//  StructWithAutowiredFactory.swift
//  DeliTests
//
//  Created by Kawoou on 23/11/2018.
//

import Deli

struct StructPayload: Payload {
    let a: Int
    let b: Bool
    let c: Float

    init(with argument: (a: Int, b: Bool, c: Float)) {
        self.a = argument.a
        self.b = argument.b
        self.c = argument.c
    }
}

struct StructWithAutowiredFactory: AutowiredFactory {
    let friendService: FriendService
    let payload: StructPayload

    init(_ friendService: FriendService, payload: StructPayload) {
        self.friendService = friendService
        self.payload = payload
    }
}
