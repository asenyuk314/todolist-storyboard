//
//  Category.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import Foundation
import RealmSwift

class Category: Object {
  @objc dynamic var id: UUID = UUID()
  @objc dynamic var name: String = ""
  @objc dynamic var color: String = ""
  @objc dynamic var date: Date = Date()
  let items = List<Item>()
}
