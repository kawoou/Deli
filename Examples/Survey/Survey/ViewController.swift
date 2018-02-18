//
//  ViewController.swift
//  Survey
//

import UIKit
import Deli

class ViewController: UITableViewController, Inject {

    let viewModel: ViewModel = Inject(ViewModel.self)
    let survay3 = Inject(Survey.self, qualifier: "Survey3")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.surveyList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        let survey = viewModel.surveyList[indexPath.item]
        cell.textLabel?.text = survey.name
        cell.detailTextLabel?.text = survey.description
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let survey = viewModel.surveyList[indexPath.item]
        let viewController = SurveyViewController(survey: survey)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
