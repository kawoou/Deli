//
//  TestSurvey3.swift
//  Survey
//

import Deli

class TestSurvey3: Survey, Component {
    
    let qualifier: String? = "Survey3"
    
    // MARK: - Property
    
    let name: String
    let description: String
    let data: [SurveyData]
    
    // MARK: - Lifecycle
    
    init() {
        name = "Test Survey 3"
        description = "Test survey form."
        data = [
            .slider(
                name: "Slider select 1",
                data: SurveySliderItem(min: 0, max: 100)
            ),
            .input(name: "Input field"),
            .slider(
                name: "Slider select 2",
                data: SurveySliderItem(min: 0, max: 100)
            )
        ]
    }
}
