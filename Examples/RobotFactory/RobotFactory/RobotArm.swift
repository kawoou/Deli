//
//  RobotArm.swift
//  DeliTest
//
//  Created by Kawoou on 14/10/2018.
//  Copyright © 2018 vbmania. All rights reserved.
//

import Deli

protocol RobotArm {
    var fileName: String { get }
}

class NormalRobotArm: RobotArm, Component {
    var qualifier: String? = "normal"

    var fileName: String = "arm-normal"
}
class SuperRobotArm: RobotArm, Component {
    var qualifier: String? = "super"

    var fileName: String = "arm-super"
}
