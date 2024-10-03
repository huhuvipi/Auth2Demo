//
//  ApplicationConfig.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation

struct ApplicationConfig : Decodable {
    let endpoint: String
    let hospitalId: Int
    let clientId: String
    let clientSecret: String
    let scope: String
    
    init() {
        self.endpoint = ""
        self.hospitalId = 0
        self.clientId = ""
        self.clientSecret = ""
        self.scope = ""
    }
    
    func getEnpointURL() throws -> URL {
        guard let url = URL(string: self.endpoint) else {
            throw ApplicationError(title: "Invalid Configuration Error", description: "The issuer URI could not be parsed")
        }
        return url
    }
    
    func getRedirectUri() -> URL {
        
        return URL(string: "zibdyhealth://redirect")!
    }
    
    func getPostLogoutRedirectUri() -> URL {
        
        return URL(string: "http://logoutexpired.com")!
        
    }
}
