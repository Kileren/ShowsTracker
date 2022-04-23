//
//  JSONReader.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 19.06.2021.
//

import Foundation

final class JSONReader {
    
    enum InternalError: Error {
        case decodingFailure
    }
    
    static func object<Object: Decodable>(forResource resource: String) throws -> Object {
        do {
            let data = try data(forResource: resource)
            return try JSONDecoder().decode(Object.self, from: data)
        } catch {
            throw error
        }
    }
    
    static func data(forResource resource: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: resource, ofType: "json") else {
            throw InternalError.decodingFailure
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            return try Data(contentsOf: url)
        } catch {
            throw error
        }
    }
}
