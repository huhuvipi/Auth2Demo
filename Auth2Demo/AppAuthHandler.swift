//
//  AppAuthHandler.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import AppAuth
import AuthenticationServices

class AppAuthHandler : NSObject {
    private let config: ApplicationConfig
    private var userAgentSession: OIDExternalUserAgentSession?
    private var loginResponseHandler: LoginResponseHandler?
    private var logoutResponseHandler: LogoutResponseHandler?
    
    init(config: ApplicationConfig) {
        self.config = config
        self.userAgentSession = nil
    }
    
    /*
     * Get OpenID Connect endpoints
     */
    func fetchMetadata() async throws -> OIDServiceConfiguration {
        
        let issuerUri = try self.config.getEnpointURL()
        
        return try await withCheckedThrowingContinuation { continuation in
            
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUri) { metadata, error in
                
                if metadata != nil {
                    
                    Logger.info(data: "Metadata retrieved successfully")
                    Logger.debug(data: metadata!.description)
                    continuation.resume(returning: metadata!)
                    
                } else {
                    
                    let error = self.createAuthorizationError(title: "Metadata Download Error", ex: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /*
     * Trigger a redirect with standard parameters
     * acr_values can be sent as an extra parameter, to control authentication methods
     */
    func performAuthorizationRedirect(
        metadata: OIDServiceConfiguration,
        clientID: String,
        viewController: UIViewController) throws {
        
        let redirectUri = try self.config.getRedirectUri()

        // Use acr_values to select a particular authentication method at runtime
        let extraParams = [String: String]()
        // extraParams["acr_values"] = "urn:se:curity:authentication:html-form:Username-Password"
        
        let scopesArray = self.config.scope.components(separatedBy: " ")
        let request = OIDAuthorizationRequest(
            configuration: metadata,
            clientId: clientID,
            clientSecret: nil,
            scopes: scopesArray,
            redirectURL: redirectUri,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams)
            self.loginResponseHandler = LoginResponseHandler()
            let authSession = ASWebAuthenticationSession(
                        url: request.externalUserAgentRequestURL()!,
                        callbackURLScheme: redirectUri.scheme
                    ) { callbackURL, error in
                        guard error == nil, let callbackURL = callbackURL else {
                            print("Authorization failed with error: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        if let error = error {
                                    // Xử lý lỗi nếu có
                                    print("Authorization error: \(error.localizedDescription)")
                                    return
                                }
                                
                                
                                // Chuyển đổi callbackURL thành OIDAuthorizationResponse
                        let response = OIDAuthorizationResponse(request: request, parameters: OIDURLQueryComponent(url: callbackURL)!.dictionaryValue)
                                
                        Logger.info(data: "Authorization succeeded with callback URL: \(callbackURL)")
                        self.loginResponseHandler?.callback(response: response, ex: error)
                        
                    }
                    
                    authSession.presentationContextProvider = self
                    authSession.start()
       
    }
    
    /*
     * Finish processing, which occurs on a worker thread
     */
    func handleAuthorizationResponse() async throws -> OIDAuthorizationResponse? {
        
        do {
            
            let response = try await self.loginResponseHandler!.waitForCallback()
            self.loginResponseHandler = nil
            return response

        } catch {
            
            self.loginResponseHandler = nil
            if (self.isUserCancellationErrorCode(ex: error)) {
                return nil
            }
            
            throw self.createAuthorizationError(title: "Authorization Request Error", ex: error)
        }
    }

    /*
     * Handle the authorization response, including the user closing the Chrome Custom Tab
     */
    func redeemCodeForTokens(clientID: String, authResponse: OIDAuthorizationResponse) async throws -> OIDTokenResponse {

        try await withCheckedThrowingContinuation { continuation in
            
            let extraParams = [String: String]()
            let request = authResponse.tokenExchangeRequest(withAdditionalParameters: extraParams)
            
            OIDAuthorizationService.perform(
                request!,
                originalAuthorizationResponse: authResponse) { tokenResponse, ex in
                    
                if tokenResponse != nil {
                    
                    Logger.info(data: "Authorization code grant response received successfully")
                    let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                    let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                    let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                    Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)" )
                    
                    continuation.resume(returning: tokenResponse!)
                    
                } else {
                    
                    let error = self.createAuthorizationError(title: "Authorization Response Error", ex: ex)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /*
     * Try to refresh an access token and return null when the refresh token expires
     */
    func refreshAccessToken(
            metadata: OIDServiceConfiguration,
            clientID: String,
            refreshToken: String) async throws -> OIDTokenResponse? {
        
        let request = OIDTokenRequest(
            configuration: metadata,
            grantType: OIDGrantTypeRefreshToken,
            authorizationCode: nil,
            redirectURL: nil,
            clientID: clientID,
            clientSecret: nil,
            scope: nil,
            refreshToken: refreshToken,
            codeVerifier: nil,
            additionalParameters: nil)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<OIDTokenResponse?, Error>) -> Void in
            
            OIDAuthorizationService.perform(request) { tokenResponse, ex in
                
                if tokenResponse != nil {
                    
                    Logger.info(data: "Refresh token code grant response received successfully")
                    let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                    let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                    let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                    Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)" )
                    
                    continuation.resume(returning: tokenResponse!)
                    
                } else {
                    
                    if ex != nil && self.isRefreshTokenExpiredErrorCode(ex: ex!) {
                        
                        Logger.info(data: "Refresh token expired and the user must re-authenticate")
                        continuation.resume(returning: nil)

                    } else {
                        
                        let error = self.createAuthorizationError(title: "Refresh Token Error", ex: ex)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /*
     * Do an OpenID Connect end session redirect and remove the SSO cookie
     */
    func performEndSessionRedirect(metadata: OIDServiceConfiguration,
                                   idToken: String,
                                   viewController: UIViewController) throws {
        
        let extraParams = [String: String]()

        let postLogoutRedirectUri = try self.config.getPostLogoutRedirectUri()
        
        let request = OIDEndSessionRequest(
            configuration: metadata,
            idTokenHint: idToken,
            postLogoutRedirectURL: postLogoutRedirectUri,
            additionalParameters: extraParams)
        
        let userAgent = OIDExternalUserAgentIOS(presenting: viewController)
        self.logoutResponseHandler = LogoutResponseHandler()
        self.userAgentSession = OIDAuthorizationService.present(
            request,
            externalUserAgent: userAgent!,
            callback: self.logoutResponseHandler!.callback)
    }
    
    /*
     * Finish processing, which occurs on a worker thread
     */
    func handleEndSessionResponse() async throws -> OIDEndSessionResponse? {
        
        do {
            
            let response = try await self.logoutResponseHandler!.waitForCallback()
            self.logoutResponseHandler = nil
            return response

        } catch {
            
            self.logoutResponseHandler = nil
            if (self.isUserCancellationErrorCode(ex: error)) {
                return nil
            }
            
            throw self.createAuthorizationError(title: "Logout Request Error", ex: error)
        }
    }

    /*
     * We can check for specific error codes to handle the user cancelling the ASWebAuthenticationSession window
     */
    private func isUserCancellationErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDGeneralErrorDomain && error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue
    }
    
    /*
     * We can check for a specific error code when the refresh token expires and the user needs to re-authenticate
     */
    private func isRefreshTokenExpiredErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDOAuthTokenErrorDomain && error.code == OIDErrorCodeOAuth.invalidGrant.rawValue
    }
    
    /*
     * Process standard OAuth error / error_description fields and also AppAuth error identifiers
     */
    private func createAuthorizationError(title: String, ex: Error?) -> ApplicationError {
        
        var parts = [String]()
        if (ex == nil) {

            parts.append("Unknown Error")

        } else {

            let nsError = ex! as NSError
            
            if nsError.domain.contains("org.openid.appauth") {
                parts.append("(\(nsError.domain) / \(String(nsError.code)))")
            }

            if !ex!.localizedDescription.isEmpty {
                parts.append(ex!.localizedDescription)
            }
        }

        let fullDescription = parts.joined(separator: " : ")
        let error = ApplicationError(title: title, description: fullDescription)
        Logger.error(data: "\(error.title) : \(error.description)")
        return error
    }
}
extension AppAuthHandler: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first ?? UIWindow() // Trả về keyWindow hoặc tạo mới UIWindow nếu không tìm thấy
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}
