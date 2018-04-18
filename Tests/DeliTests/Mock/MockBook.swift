//
//  MockBook.swift
//  DeliTests
//
//  Created by Kawoou on 2018. 4. 14..
//

import Deli

class MockBook: Book, Component {
    var qualifier: String? {
        return "Test"
    }
    var category: String {
        return "Test"
    }
}
