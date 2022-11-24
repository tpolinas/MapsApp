//
//  RealmAnnotation.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 23.11.2022.
//

import Foundation
import RealmSwift

class AnnotationRealm: Object {
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    @Persisted(primaryKey: true) var id = UUID()
    
    convenience init(original: Annotation) {
        self.init()
        self.latitude = original.lat
        self.longitude = original.long
    }
}

class Annotation {
    var lat: Double
    var long: Double
    
    init(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }
}
