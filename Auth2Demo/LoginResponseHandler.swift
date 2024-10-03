//
//  LoginResponseHandler.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import AppAuth

class LoginResponseHandler {

    var storedContinuation: CheckedContinuation<OIDAuthorizationResponse?, Error>?

    /*
     * Set a continuation and await
     */
    func waitForCallback() async throws -> OIDAuthorizationResponse? {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }

    /*
     * On Completion, this is called by AppAuth libraries on the UI thread, and code resumes
     */
    func callback(response: OIDAuthorizationResponse?, ex: Error?) {
        
        if ex != nil {
            storedContinuation?.resume(throwing: ex!)
        } else {
            storedContinuation?.resume(returning: response)
        }
    }
}

