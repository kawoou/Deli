//
//  RobotBody.swift
//  DeliTest
//
//  Created by Kawoou on 13/10/2018.
//  Copyright © 2018 vbmania. All rights reserved.
//

import Deli

protocol RobotBody {
    var fileName: String { get }
}

class RedRobotBody: RobotBody, Component {
    var qualifier: String? = "red"
    
    var fileName: String = "body-red"
}
class BlueRobotBody: RobotBody, Component {
    var qualifier: String? = "blue"

    var fileName: String = "body-blue"
}
