//
//  AppDelegate.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
      switch oldSchemaVersion {
      case ..<2:
        migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
          newObject![K.itemFields.dateField] = Date()
        }
      default:
        break
      }
    })

    Realm.Configuration.defaultConfiguration = config
    do {
      _ = try Realm()
    } catch {
      let nsError = error as NSError
      fatalError("Error initializing realm \(nsError), \(nsError.userInfo)")
    }

    return true
  }
  
  // MARK: - UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

  }
}
