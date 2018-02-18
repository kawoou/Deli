//
//  Survey.swift
//  Survey
//

protocol Survey {
    var name: String { get }
    var description: String { get }
    var data: [SurveyData] { get }
}
