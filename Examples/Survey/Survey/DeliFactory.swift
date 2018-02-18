//
//  Deli Factory
//  Auto generated code.
//

import Deli

final class DeliFactory {
    let context: AppContextType

    init() {
        let context = AppContext.shared
        context.register(
            SurveyServiceImpl.self,
            resolver: {
                let _Survey = context.get([Survey].self, qualifier: "")
                return SurveyServiceImpl(_Survey)
            },
            qualifier: "",
            scope: .singleton
        ).link(SurveyService.self)
        context.register(
            TestSurvey1.self,
            resolver: {
                return TestSurvey1()
            },
            qualifier: "Survey1",
            scope: .singleton
        ).link(Survey.self)
        context.register(
            TestSurvey2.self,
            resolver: {
                return TestSurvey2()
            },
            qualifier: "Survey2",
            scope: .singleton
        ).link(Survey.self)
        context.register(
            TestSurvey3.self,
            resolver: {
                return TestSurvey3()
            },
            qualifier: "Survey3",
            scope: .singleton
        ).link(Survey.self)
        context.register(
            ViewModel.self,
            resolver: {
                let _SurveyService = context.get(SurveyService.self, qualifier: "")!
                return ViewModel(_SurveyService)
            },
            qualifier: "",
            scope: .singleton
        )

        self.context = context
    }
}