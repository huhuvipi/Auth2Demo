//
//  ContentView.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

struct MainView: View {

    @ObservedObject private var model: MainViewModel

    init(model: MainViewModel) {
        self.model = model
    }
    
    var body: some View {
        
        return VStack {
        
            Text("main_title")
                .headingStyle()
                .padding(.top, 20)
                .padding(.leading, 20)
            
            if (!self.model.isAuthenticated) {
                UnauthenticatedView(model: self.model.getUnauthenticatedViewModel())
            } else {
                AuthenticatedView(model: self.model.getAuthenticatedViewModel())
            }
        }
    }
}
