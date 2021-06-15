//
//  ManagedObjectCodable.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import CoreData

protocol ManagedObjectEncodable: Equatable {
    associatedtype ManagedObject: NSManagedObject & ManagedObjectDecodable
    
    var id: String { get }
    
    func encode(in context: NSManagedObjectContext)
}

protocol ManagedObjectDecodable {
    associatedtype Object: ManagedObjectEncodable
    
    func decode() -> Object
    func change(with object: Object)
}
