//
//  SurveyViewController.swift
//  Survey
//
//  Created by Kawoou on 2018. 3. 28..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {
    
    let survey: Survey
    
    private var lastOffset: CGFloat = 100
    private func makeTitle(_ name: String) {
        let rect = CGRect(
            x: 20,
            y: lastOffset + 20,
            width: view.frame.width - 40,
            height: 20
        )
        lastOffset += 50
        
        let titleView = UILabel(frame: rect)
        titleView.text = name
        view.addSubview(titleView)
    }
    private func makeTextField() {
        let rect = CGRect(
            x: 20,
            y: lastOffset,
            width: view.frame.width - 40,
            height: 30
        )
        lastOffset += 40
        
        let textField = UITextField(frame: rect)
        textField.borderStyle = .line
        view.addSubview(textField)
    }
    private func makeSlider(_ data: SurveySliderItem) {
        let rect = CGRect(
            x: 20,
            y: lastOffset,
            width: view.frame.width - 40,
            height: 30
        )
        lastOffset += 40
        
        let slider = UISlider(frame: rect)
        slider.minimumValue = Float(data.min)
        slider.maximumValue = Float(data.max)
        slider.value = Float(data.min)
        view.addSubview(slider)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = survey.name
        
        for data in survey.data {
            switch data {
            case .input(name: let name):
                makeTitle(name)
                makeTextField()
                
            case .slider(name: let name, data: let data):
                makeTitle(name)
                makeSlider(data)
            }
        }
    }
    
    init(survey: Survey) {
        self.survey = survey
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
