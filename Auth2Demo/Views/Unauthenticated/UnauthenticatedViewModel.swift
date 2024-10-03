//
//  UnauthenticatedViewModel.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation
import AppAuth

class UnauthenticatedViewModel: ObservableObject {
    
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let onLoggedIn: () -> Void
    
    @Published var error: ApplicationError?
    
    init(
        config: ApplicationConfig,
        state: ApplicationStateManager,
        appauth: AppAuthHandler,
        onLoggedIn: @escaping () -> Void) {
            
            self.config = config
            self.state = state
            self.appauth = appauth
            self.onLoggedIn = onLoggedIn
            self.error = nil
        }
    
    /*
     * Run front channel operations on the UI thread and back channel operations on a background thread
     */
    func startLogin() {
        
        Task {
            
            do {
                
                // Get metadata
                let metadata = try await self.appauth.fetchMetadata()
                
                // Initiate the redirect on the UI thread
                try await MainActor.run {
                    
                    self.error = nil
                    try self.appauth.performAuthorizationRedirect(
                        metadata: metadata,
                        clientID: self.config.clientId,
                        viewController: self.getViewController()
                    )
                }
                
                // Wait for the response
                let authorizationResponse = try await self.appauth.handleAuthorizationResponse()
                if authorizationResponse != nil {
                    
                    // Redeem the code for tokens
                    let tokenResponse = try await self.appauth.redeemCodeForTokens(
                        clientID: self.config.clientId,
                        authResponse: authorizationResponse!)
                    
                    // Update application state on the UI thread, then move the app to the authenticated view
                    await MainActor.run {
                        self.state.metadata = metadata
                        self.state.saveTokens(tokenResponse: tokenResponse)
                        self.onLoggedIn()
                    }
                }
                
            } catch {
                
                // Handle errors on the UI thread
                await MainActor.run {
                    let appError = error as? ApplicationError
                    if appError != nil {
                        self.error = appError!
                    }
                }
            }
        }
    }
    
    private func getViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene!.keyWindow!.rootViewController!
        
    }
}
