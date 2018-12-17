//
//  DeliFactory.swift
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        loadProperty([:])

        register(
            AngryRobotHead.self,
            resolver: {
                return AngryRobotHead()
            },
            qualifier: "angry",
            scope: .singleton
        ).link(RobotHead.self)
        register(
            BlueRobotBody.self,
            resolver: {
                return BlueRobotBody()
            },
            qualifier: "blue",
            scope: .singleton
        ).link(RobotBody.self)
        register(
            BusanFactoryRobot.self,
            resolver: {
                let _0 = context.get(RobotHead.self, qualifier: "happy")!
                let _1 = context.get(RobotBody.self, qualifier: "blue")!
                let _2 = context.get(RobotLeg.self, qualifier: "normal")!
                let _3 = context.get(RobotArm.self, qualifier: "super")!
                return BusanFactoryRobot(happy: _0, blue: _1, normal: _2, super: _3)
            },
            qualifier: "busan",
            scope: .singleton
        ).link(Robot.self)
        register(
            HappyRobotHead.self,
            resolver: {
                return HappyRobotHead()
            },
            qualifier: "happy",
            scope: .singleton
        ).link(RobotHead.self)
        register(
            IncheonFactoryRobot.self,
            resolver: {
                let _0 = context.get(RobotHead.self, qualifier: "happy")!
                let _1 = context.get(RobotBody.self, qualifier: "blue")!
                let _2 = context.get(RobotLeg.self, qualifier: "rocket")!
                let _3 = context.get(RobotArm.self, qualifier: "normal")!
                return IncheonFactoryRobot(happy: _0, blue: _1, rocket: _2, normal: _3)
            },
            qualifier: "incheon",
            scope: .singleton
        ).link(Robot.self)
        register(
            NormalRobotArm.self,
            resolver: {
                return NormalRobotArm()
            },
            qualifier: "normal",
            scope: .singleton
        ).link(RobotArm.self)
        register(
            NormalRobotLeg.self,
            resolver: {
                return NormalRobotLeg()
            },
            qualifier: "normal",
            scope: .singleton
        ).link(RobotLeg.self)
        register(
            RedRobotBody.self,
            resolver: {
                return RedRobotBody()
            },
            qualifier: "red",
            scope: .singleton
        ).link(RobotBody.self)
        register(
            RocketRobotLeg.self,
            resolver: {
                return RocketRobotLeg()
            },
            qualifier: "rocket",
            scope: .singleton
        ).link(RobotLeg.self)
        register(
            SeoulFactoryRobot.self,
            resolver: {
                let _0 = context.get(RobotHead.self, qualifier: "angry")!
                let _1 = context.get(RobotBody.self, qualifier: "red")!
                let _2 = context.get(RobotLeg.self, qualifier: "normal")!
                let _3 = context.get(RobotArm.self, qualifier: "super")!
                return SeoulFactoryRobot(angry: _0, red: _1, normal: _2, super: _3)
            },
            qualifier: "seoul",
            scope: .singleton
        ).link(Robot.self)
        register(
            SuperRobotArm.self,
            resolver: {
                return SuperRobotArm()
            },
            qualifier: "super",
            scope: .singleton
        ).link(RobotArm.self)
    }
}