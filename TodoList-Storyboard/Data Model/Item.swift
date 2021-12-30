//
//  Item.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import Foundation
import RealmSwift

class Item: Object {
  @objc dynamic var id: UUID = UUID()
  @objc dynamic var name: String = ""
  @objc dynamic var done: Bool = false
  @objc dynamic var date: Date = Date()
  var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
