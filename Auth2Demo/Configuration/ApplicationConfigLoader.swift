//
//  ApplicationConfigLoader.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//

import Foundation

struct ApplicationConfigLoader {

    static func load() throws -> ApplicationConfig {
        let configFilePath = Bundle.main.path(forResource: "config", ofType: "json")
        let jsonText = try String(contentsOfFile: configFilePath!, encoding: .utf8)
        let jsonData = jsonText.data(using: .utf8)!
        let decoder = JSONDecoder()

        let data =  try decoder.decode(ApplicationConfig.self, from: jsonData)
        return data
    }
}
 
