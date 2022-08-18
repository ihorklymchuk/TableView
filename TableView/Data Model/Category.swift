//
//  Category.swift
//  TableView
//
//  Created by Ihor Klymchuk on 17/08/2022.
//

import Foundation
import RealmSwift

class Category: Object { 
    
    @objc dynamic var name: String = ""
    let items = List<Item>()
    
}
