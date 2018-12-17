//
//  RobotLeg.swift
//  DeliTest
//
//  Created by Kawoou on 13/10/2018.
//  Copyright © 2018 vbmania. All rights reserved.
//

import Deli

protocol RobotLeg {
    var fileName: String { get }
}

class RocketRobotLeg: RobotLeg, Component {
    var qualifier: String? = "rocket"

    var fileName: String = "leg-rocket"
}
class NormalRobotLeg: RobotLeg, Component {
    var qualifier: String? = "normal"
    
    var fileName: String = "leg-normal"
}
