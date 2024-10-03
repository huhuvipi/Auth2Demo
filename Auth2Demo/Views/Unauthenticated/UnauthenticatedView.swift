//
//  UnauthenticatedView.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

struct UnauthenticatedView: View {
    
    @ObservedObject private var model: UnauthenticatedViewModel
    
    init(model: UnauthenticatedViewModel) {
        self.model = model
    }
    
    var body: some View {

        let isEnabled = true
        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
            }
            
            Text("welcome_message")
                .labelStyle()
                .padding(.top, 20)
            
            Image("StartIllustration")
                .aspectRatio(contentMode: .fit)
                .padding(.top, 20)
            
            Button(action: self.model.startLogin) {
               Text("start_authentication")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: !isEnabled))
            .disabled(!isEnabled)
            
            Spacer()
        }
    }
}
