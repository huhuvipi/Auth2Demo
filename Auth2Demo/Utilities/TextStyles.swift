//
//  TextStyles.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import SwiftUI

extension Text {
    
    func headingStyle() -> Text {

        return foregroundColor(Color.black)
                 .font(.system(size: 28))
                 .fontWeight(.semibold)
    }
    
    func labelStyle() -> Text {

       return foregroundColor(Color.gray)
                 .font(.system(size: 20))
                 .fontWeight(.semibold)
    }

    func valueStyle() -> Text {

        return foregroundColor(Color.blue)
                 .font(.system(size: 16))
                 .fontWeight(.semibold)
    }

    func errorValueStyle() -> Text {

        return foregroundColor(Color.red)
                 .font(.system(size: 16))
                 .fontWeight(.semibold)
    }
}

