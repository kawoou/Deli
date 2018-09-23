//
//  AppDelegate.swift
//  GitHubSearch
//

import UIKit
import Deli

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let context = AppContext.shared.load([
        GitHubFactory.self
    ])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
