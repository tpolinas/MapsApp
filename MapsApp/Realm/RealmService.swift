//
//  RealmService.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import RealmSwift

struct PersistenceError: Swift.Error {
    enum ErrorsCodes: Int {
        case objectMissing = 0
        
        func getDescription() -> String {
            switch self {
            case .objectMissing:
                return "Realm object is missing"
            }
        }
    }
    
    var code: Int
    var description: String
}

final class RealmService {
    static let deleteIfMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    static func save<T: Object>(
        items: [T],
        configuration: Realm.Configuration = deleteIfMigration,
        update: Realm.UpdatePolicy = .modified
    ) throws {
        let realm = try Realm(configuration: configuration)
        print(configuration.fileURL ?? "")
        try realm.write({
            realm.add(items, update: update)
        })
    }
    
    static func saveSingleObject<T: Object>(
        items: T,
        configuration: Realm.Configuration = deleteIfMigration,
        update: Realm.UpdatePolicy = .modified
    ) throws {
        let realm = try Realm(configuration: configuration)
        print(configuration.fileURL ?? "")
        try realm.write({
            realm.add(items, update: update)
        })
    }
    
    static func load<T: Object>(
        typeOf: T.Type
    ) throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(T.self)
    }
    
    static func deleteAll() throws {
        let realm = try Realm()
        try realm.write({
            realm.deleteAll()
        })
    }
    
    static func delete<T: Object>(
        object: Results<T>
    ) throws {
        let realm = try Realm()
        try realm.write({
            realm.delete(object)
        })
    }
    
    static func updateObject<T: Object>(
        _ object: T,
        key: String
    ) throws where T: Object {
        let realm = try Realm()
        let result = realm.object(ofType: T.self, forPrimaryKey: key)
        if let object = result {
            try realm.write({
                realm.add(object, update: .modified)
            })
        } else {
            let errorDescription = PersistenceError.ErrorsCodes.objectMissing
            throw PersistenceError(code: errorDescription.rawValue, description: errorDescription.getDescription())
        }
    }
    
    static func get<T: Object>(
        type: T.Type,
        configuration: Realm.Configuration = deleteIfMigration
    ) throws -> Results<T> {
        let realm = try Realm(configuration: configuration)
        print(configuration.fileURL ?? "")
        return realm.objects(T.self)
    }
}
