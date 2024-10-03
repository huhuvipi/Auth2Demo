//
//  Logger.swift
//  Auth2Demo
//
//  Created by Vinh Huynh on 2/10/24.
//
import os.log

struct Logger {
    
    static func error(data: String) {
        os_log("%s", type: .error, data)
    }

    static func info(data: String) {
        os_log("%s", type: .info, data)
    }

    static func debug(data: String) {
        os_log("%s", type: .debug, data)
    }
}
