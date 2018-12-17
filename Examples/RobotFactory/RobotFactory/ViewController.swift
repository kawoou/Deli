//
//  ViewController.swift
//  RobotFactory
//
//  Created by Kawoou on 18/12/2018.
//  Copyright © 2018 kawoou. All rights reserved.
//

import UIKit

import Deli

class ViewController: UIViewController, Inject {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var headView: UIImageView!
    @IBOutlet weak var bodyView: UIImageView!
    @IBOutlet weak var armView: UIImageView!
    @IBOutlet weak var legView: UIImageView!

    private let robots = Inject([Robot].self).sorted { $0.madeIn < $1.madeIn }

    private func updateRobot(_ robot: Robot) {
        headView.image = UIImage(named: robot.head.fileName)
        bodyView.image = UIImage(named: robot.body.fileName)
        armView.image = UIImage(named: robot.arm.fileName)
        legView.image = UIImage(named: robot.leg.fileName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.removeAllSegments()
        for (index, robot) in robots.enumerated() {
            segmentedControl.insertSegment(withTitle: robot.madeIn, at: index, animated: false)
        }

        segmentedControl.selectedSegmentIndex = 0
        updateRobot(robots[0])
    }

    @IBAction func changeSegmentedControl(_ sender: UISegmentedControl) {
        updateRobot(robots[sender.selectedSegmentIndex])
    }
}

