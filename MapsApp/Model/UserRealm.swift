//
//  UserRealm.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import Foundation
import RealmSwift

class UserRealm: Object {
    @Persisted(primaryKey: true) var login: String = ""
    @Persisted var password: String = ""
    
    convenience init(_ user: User) {
        self.init()
        self.login = user.login
        self.password = user.password
    }
}

class User {
    var login: String
    var password: String
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}
