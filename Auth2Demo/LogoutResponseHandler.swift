//
//  LogoutResponseHandler.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import AppAuth

class LogoutResponseHandler {

    var storedContinuation: CheckedContinuation<OIDEndSessionResponse?, Error>?

    /*
     * Set a continuation and await
     */
    func waitForCallback() async throws -> OIDEndSessionResponse? {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }

    /*
     * On completion, this is called by AppAuth libraries on the UI thread, and code resumes
     */
    func callback(response: OIDEndSessionResponse?, ex: Error?) {
        
        if ex != nil {
            storedContinuation?.resume(throwing: ex!)
        } else {
            storedContinuation?.resume(returning: response)
        }
    }
}


