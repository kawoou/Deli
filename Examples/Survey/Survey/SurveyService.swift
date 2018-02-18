//
//  SurveyService.swift
//  Survey
//

import Deli

protocol SurveyService {
    var surveyList: [Survey] { get }
}
class SurveyServiceImpl: SurveyService, Autowired {
    let surveyList: [Survey]
    
    required init(_ surveyList: [Survey]) {
        self.surveyList = surveyList
    }
}
