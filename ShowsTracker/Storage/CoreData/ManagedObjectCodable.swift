//
//  ManagedObjectCodable.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import CoreData

protocol ManagedObjectEncodable: Equatable {
    associatedtype ManagedObject: NSManagedObject & ManagedObjectDecodable
    
    var id: Int { get }
}

protocol ManagedObjectDecodable {
    associatedtype Object: ManagedObjectEncodable
    
    var object: Object { get set }
}
