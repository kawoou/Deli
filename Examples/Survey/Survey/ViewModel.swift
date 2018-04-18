//
//  ViewModel.swift
//  Survey
//

import Deli

class ViewModel: Autowired {
    
    // MARK: - Deli
    
    let scope: Scope = .prototype
    
    // MARK: - Property
    
    let surveyList: [Survey]
    
    // MARK: - Private
    
    private let surveyService: SurveyService
    
    // MARK: - Lifecycle
    
    required init(_ surveyService: SurveyService) {
        self.surveyService = surveyService
        
        surveyList = surveyService.surveyList
            .sorted { $0.name < $1.name }
    }
}

