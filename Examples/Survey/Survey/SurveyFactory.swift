//
//  SurveyFactory.swift
//  Auto generated code.
//

import Deli

final class SurveyFactory: ModuleFactory {
    override func load(context: AppContext) {
        register(
            SurveyServiceImpl.self,
            resolver: {
                let _Survey = context.get([Survey].self, qualifier: "")
                return SurveyServiceImpl(_Survey)
            },
            qualifier: "",
            scope: .singleton
        ).link(SurveyService.self)
        register(
            TestSurvey1.self,
            resolver: {
                return TestSurvey1()
            },
            qualifier: "Survey1",
            scope: .singleton
        ).link(Survey.self)
        register(
            TestSurvey2.self,
            resolver: {
                return TestSurvey2()
            },
            qualifier: "Survey2",
            scope: .singleton
        ).link(Survey.self)
        register(
            TestSurvey3.self,
            resolver: {
                return TestSurvey3()
            },
            qualifier: "Survey3",
            scope: .singleton
        ).link(Survey.self)
        register(
            ViewModel.self,
            resolver: {
                let _SurveyService = context.get(SurveyService.self, qualifier: "")!
                return ViewModel(_SurveyService)
            },
            qualifier: "",
            scope: .prototype
        )
    }

    required init() {}
}