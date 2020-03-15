//
//  DependencyTestModel.swift
//  Deli
//
//  Created by Kawoou on 2020/03/06.
//

import Deli

struct DependencyTestModel {
    @Dependency var test1: PropertyWrapperTest1
    @Dependency(qualifier: "google") var googleAccountService: AccountService
    @Dependency(qualifierBy: "server.method") var method: NetworkMethod

    @DependencyArray var test2: [PropertyWrapperTest2]
    @DependencyArray(qualifier: "google") var accountServices: [AccountService]
    @DependencyArray(qualifierBy: "server.method") var methods: [NetworkMethod]

    @PropertyValue("server.url") var propertyValue: String

    init() {}
}
