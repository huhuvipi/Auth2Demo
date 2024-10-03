//
//  ApplicationError.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation

class ApplicationError: Error {
    
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}
