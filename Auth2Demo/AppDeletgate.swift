//
//  AppDeletgate.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//
import UIKit
import AppAuth

class AppDelegate: UIResponder, UIApplicationDelegate {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authorizationFlow = self.currentAuthorizationFlow,
           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }
        return false
    }
}
