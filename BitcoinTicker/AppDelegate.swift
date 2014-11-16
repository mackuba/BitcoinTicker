//
//  AppDelegate.swift
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    @IBOutlet var mainScreenController: MainScreenViewController?

    func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        mainScreenController?.refreshPrice()
    }
}
