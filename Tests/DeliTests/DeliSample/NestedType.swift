//
//  NestedType.swift
//  Deli
//
//  Created by Kawoou on 2020/01/14.
//

import Deli

class NestedClass {
    struct NestedStruct: Component {
        
    }
}

struct NestedStruct {
    class NestedClass: Component {

    }
}

extension NestedStruct.NestedClass {
    struct NestedStruct {
        class NestedClass: Component {

        }
    }
}

class NestedTestClass: Autowired {
    typealias NestedType = NestedStruct.NestedClass.NestedStruct.NestedClass

    let a: NestedClass.NestedStruct
    let b: NestedStruct.NestedClass
    let c: NestedType

    required init(_ a: NestedClass.NestedStruct, _ b: NestedStruct.NestedClass, _ c: NestedType) {
        self.a = a
        self.b = b
        self.c = c
    }
}
