//
//  Auth2DemoApp.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import AppAuth
import SwiftUI



@main
struct Auth2DemoApp: App {
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let model: MainViewModel
    @UIApplicationDelegateAdaptor(AppDelegate.self)  var appDelegate

    init() {
        self.config = try! ApplicationConfigLoader.load()
        self.state = ApplicationStateManager()
        self.appauth = AppAuthHandler(config: self.config)
        self.model = MainViewModel(config: self.config, state: self.state, appauth: self.appauth)
    }

    var body: some Scene {
        WindowGroup {
            MainView(model: self.model)
        }
    }
}
