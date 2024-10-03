//
//  ErrorViewModel.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation

class ErrorViewModel: ObservableObject {

    @Published var title = ""
    @Published var description = ""
    
    init(error: ApplicationError) {
        self.title = error.title
        self.description = error.description.isEmpty ? "Unknown Error" : error.description
    }

    func clearDetails() {
        self.title = ""
        self.description = ""
    }

    func hasDetails() -> Bool {
        return !self.title.isEmpty
    }
}
