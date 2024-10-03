//
//  ErrorView.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

struct ErrorView: View {

    @ObservedObject private var model: ErrorViewModel
    
    init(model: ErrorViewModel) {
        self.model = model
    }
    
    var body: some View {
    
        return VStack {
            
            Text(self.model.title)
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)

            Text(self.model.description)
                .errorValueStyle()
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    }
}
