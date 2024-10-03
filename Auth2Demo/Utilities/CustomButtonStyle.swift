//
//  CustomButtonStyle.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    private let disabled: Bool

    init (disabled: Bool = false) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {

        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            .foregroundColor(.white)
            .background(Color("PrimaryDark"))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(self.disabled ? 0.5 : 1.0)
            .cornerRadius(8)
            .disabled(self.disabled)
    }
}
