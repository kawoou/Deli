//
//  TestSurvey1.swift
//  Survey
//

import Deli

class TestSurvey1: Survey, Component {
    
    var qualifier: String? = "Survey1"
    
    // MARK: - Property
    
    let name: String
    let description: String
    let data: [SurveyData]
    
    // MARK: - Lifecycle
    
    init() {
        name = "Test Survey 1"
        description = "Test survey form."
        data = [
            .input(name: "Input field 1"),
            .input(name: "Input field 2"),
            .slider(
                name: "Slider select",
                data: SurveySliderItem(min: 0, max: 100)
            )
        ]
    }
}
