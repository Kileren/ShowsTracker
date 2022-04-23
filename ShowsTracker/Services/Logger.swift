//
//  Logger.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Foundation
import Moya

struct Logger {
    static func log(message: String) {
        print("✉️ \(message)")
    }
    
    static func log(error: Error, response: Response? = nil, file: String = #file, line: Int = #line) {
        printSeparator()
        defer { printSeparator() }
        
        print("❌ Error - \(String(describing: error))")
        print("ℹ️ File - \(file)")
        print("ℹ️ Line - \(line)")
        printInfo(from: response)
    }
    
    static func log<T>(response: Response, parsedTo type: T) {
        printSeparator()
        defer { printSeparator() }
        
        print("✅ Successfully parsed")
        print("ℹ️ Result Type: \(String(describing: type))")
        printInfo(from: response)
    }
}

fileprivate extension Logger {
    static func printInfo(from response: Response?) {
        guard let request = response?.request else { return }
        
        print("ℹ️ Request - \(request.url?.description ?? "")")
        print("ℹ️ Method  - \(request.method?.rawValue ?? "")")
        print("ℹ️ Headers - \(request.headers)")
        
        if let body = request.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] {
            print("ℹ️ Body ⤵️")
            json.forEach { key, value in
                print("        ➡️ \(key): \(value)")
            }
        }
    }
    
    static func printSeparator() {
        print("----------------------------------------------------------")
    }
}
