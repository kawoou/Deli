//
//  TestPayload.swift
//  GitHubSearch
//
//  Created by Kawoou on 2018. 5. 1..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli

class TestPayload: Payload {
    let test: String
    
    required init(with userID: (String)) {
        self.test = userID
    }
}
