//
//  AuthenticatedViewModel.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation
import AppAuth
import SwiftJWT

class AuthenticatedViewModel: ObservableObject {

    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let onLoggedOut: (() -> Void)

    @Published var hasRefreshToken: Bool
    @Published var hasIdToken: Bool
    @Published var subject: String
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var error: ApplicationError?
    
    struct IDTokenClaims: Claims {
        var sub: String
    }
    
    init(
        config: ApplicationConfig,
        state: ApplicationStateManager,
        appauth: AppAuthHandler,
        onLoggedOut: @escaping () -> Void) {

        self.config = config
        self.state = state
        self.appauth = appauth
        self.onLoggedOut = onLoggedOut
        self.hasRefreshToken = false
        self.hasIdToken = false
        self.subject = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.error = nil
    }

    /*
     * Show token information after login
     */
    func processTokens() {

        if self.state.toki/ZibdyFHIR/downloadResources?userStringId=iIo6NUSIbqI%3d&id=40827enResponse?.accessToken != nil {
            self.accessToken = self.state.tokenResponse!.accessToken!
        }

        if self.state.tokenResponse?.refreshToken != nil {
            self.hasRefreshToken = true
            self.refreshToken = self.state.tokenResponse!.refreshToken!
        }
        
        if self.state.idToken != nil {
            
            let idToken = self.state.idToken!
            self.hasIdToken = true
            
            do {

                let jwt = try JWT<IDTokenClaims>(jwtString: idToken)
                self.subject = jwt.claims.sub

            } catch {
                
                let appError = ApplicationError(title: "Failed to parse ID Token", description: error.localizedDescription)
                Logger.error(data: appError.description)
                self.error = appError
            }
        }
    }

    /*
     * Perform a refresh token grant message
     */
    func refreshAccessToken() {
        
        let metadata = self.state.metadata!
        let refreshToken = self.state.tokenResponse!.refreshToken!
        self.error = nil
        
        Task {

            do {

               let tokenResponse = try await self.appauth.refreshAccessToken(
                    metadata: metadata,
                    clientID: self.config.clientId,
                    refreshToken: refreshToken)
                
                await MainActor.run {
                    
                    if tokenResponse != nil {
                        self.state.saveTokens(tokenResponse: tokenResponse!)
                        self.processTokens()
                        
                    } else {
                        self.state.clearTokens()
                        self.onLoggedOut()
                    }
                }

            } catch {
                
                await MainActor.run {
                    
                    let appError = error as? ApplicationError
                    if appError != nil {
                        self.error = appError!
                    }
                }
            }
        }
    }

    /*
     * Run the end session redirect and handle the response
     */
    func startLogout() {

        Task {

            do {

                self.error = nil

                // Initiate the redirect on the UI thread
                try await MainActor.run {

                    try self.appauth.performEndSessionRedirect(
                        metadata: self.state.metadata!,
                        idToken: self.state.idToken!,
                        viewController: self.getViewController()
                    )
                }
                
                // Wait for the response
                let _ = try await self.appauth.handleEndSessionResponse()

                // Then update state on the UI thread
                await MainActor.run {
                    self.state.clearTokens()
                    self.onLoggedOut()
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
