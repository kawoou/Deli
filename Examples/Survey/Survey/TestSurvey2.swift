//
//  TestSurvey2.swift
//  Survey
//

import Deli

class TestSurvey2: Survey, Component {
    
    var qualifier = "Survey2"
    
    // MARK: - Property
    
    let name: String
    let description: String
    let data: [SurveyData]
    
    // MARK: - Lifecycle
    
    init() {
        name = "Test Survey 2"
        description = "Test survey form."
        data = [
            .input(name: "Input field"),
            .slider(
                name: "Slider select",
                data: SurveySliderItem(min: 0, max: 100)
            )
        ]
    }
}
