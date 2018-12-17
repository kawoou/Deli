//
//  RobotHead.swift
//  DeliTest
//
//  Created by Kawoou on 13/10/2018.
//  Copyright © 2018 vbmania. All rights reserved.
//

import Deli

protocol RobotHead {
    var fileName: String { get }
}

class AngryRobotHead: RobotHead, Component {
    var qualifier: String? = "angry"

    var fileName: String = "head-angry"
}
class HappyRobotHead: RobotHead, Component {
    var qualifier: String? = "happy"
    
    var fileName: String = "head-happy"
}
