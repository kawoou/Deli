//
//  ViewController.swift
//  GitHubSearch
//

import SafariServices
import UIKit
import Deli
import RxCocoa
import RxSwift
import RxOptional

class ViewController: UIViewController, Inject {
    
    // MARK: - Interface
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Private
    
    private let disposeBag = DisposeBag()
    private let viewModel = Inject(ViewModel.self)

    // MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()

        unowned let viewModel = self.viewModel
        
        searchBar.rx.text
            .filterNil()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .map { SearchRequest(query: $0, page: 1) }
            .bind(to: viewModel.searchRequest)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [unowned self] offset in
                let height = self.tableView.frame.height
                let contentHeight = self.tableView.contentSize.height
                
                guard height > 0 else { return false }
                guard contentHeight > 0 else { return false }
                return offset.y + height >= contentHeight - height / 2
            }
            .flatMapLatest { _ in viewModel.response.take(1) }
            .filterNil()
            .filter { $0.nextPage != nil }
            .map { SearchRequest(query: $0.query, page: $0.nextPage!) }
            .bind(to: viewModel.searchRequest)
            .disposed(by: disposeBag)
        
        viewModel.response
            .filterNil()
            .map { $0.repos }
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { (_, repo, cell) in
                cell.textLabel?.text = repo
            }
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { viewModel.response.value?.repos[$0.row] }
            .filterNil()
            .subscribe(onNext: { [weak self] repo in
                guard let ss = self else { return }
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let viewController = SFSafariViewController(url: url)
                ss.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
