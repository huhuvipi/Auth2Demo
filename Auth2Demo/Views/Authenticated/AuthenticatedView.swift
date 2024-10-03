//
//  AuthenticatedView.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

struct AuthenticatedView: View {
    
    @ObservedObject private var model: AuthenticatedViewModel
    
    init(model: AuthenticatedViewModel) {
        self.model = model
    }
    
    var body: some View {
    
        let deviceWidth = UIScreen.main.bounds.size.width
        let refreshEnabled = self.model.hasRefreshToken
        let signOutEnabled = self.model.hasIdToken

        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
            }
           
            Text("subject")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
                
            Text(self.model.subject)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Text("access_token")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Text(self.model.accessToken)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)

            Text("refresh_token")
                .labelStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)

            Text(self.model.refreshToken)
                .valueStyle()
                .padding(.leading, 20)
                .frame(width: deviceWidth, alignment: .leading)
            
            Button(action: self.model.refreshAccessToken) {
               Text("refresh_access_token")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: !refreshEnabled))
            .disabled(!refreshEnabled)
            
            Button(action: self.model.startLogout) {
               Text("sign_out")
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .buttonStyle(CustomButtonStyle(disabled: !signOutEnabled))
            .disabled(!signOutEnabled)
            
            Spacer()
        }
        .onAppear(perform: self.onViewCreated)
    }
    
    func onViewCreated() {
        self.model.processTokens()
    }
}
