//
//  Robot.swift
//  DeliTest
//
//  Created by Kawoou on 13/10/2018.
//  Copyright © 2018 vbmania. All rights reserved.
//

import Deli

protocol Robot {
    var qualifier: String? { get }

    var madeIn: String { get }
    
    var head: RobotHead { get }
    var body: RobotBody { get }
    var leg: RobotLeg { get }
    var arm: RobotArm { get }
}

class SeoulFactoryRobot: Robot, Autowired {
    var qualifier: String? = "seoul"

    let madeIn = "Seoul"

    let head: RobotHead
    let body: RobotBody
    let leg: RobotLeg
    let arm: RobotArm

    required init(
        angry head: RobotHead,
        red body: RobotBody,
        normal leg: RobotLeg,
        super arm: RobotArm
    ) {
        self.head = head
        self.body = body
        self.leg = leg
        self.arm = arm
    }
}
class IncheonFactoryRobot: Robot, Autowired {
    var qualifier: String? = "incheon"

    let madeIn = "Incheon"

    let head: RobotHead
    let body: RobotBody
    var leg: RobotLeg
    let arm: RobotArm

    required init(
        happy head: RobotHead,
        blue body: RobotBody,
        rocket leg: RobotLeg,
        normal arm: RobotArm
    ) {
        self.head = head
        self.body = body
        self.leg = leg
        self.arm = arm
    }
}
class BusanFactoryRobot: Robot, Autowired {
    var qualifier: String? = "busan"

    let madeIn = "Busan"

    let head: RobotHead
    let body: RobotBody
    var leg: RobotLeg
    let arm: RobotArm

    required init(
        happy head: RobotHead,
        blue body: RobotBody,
        normal leg: RobotLeg,
        super arm: RobotArm
    ) {
        self.head = head
        self.body = body
        self.leg = leg
        self.arm = arm
    }
}
