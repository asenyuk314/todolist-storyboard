//
//  SwipeTableViewController.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 60
    tableView.separatorStyle = .none
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    let deleteAction = SwipeAction(style: .destructive, title: "Удалить") { action, indexPath in
      self.updateModel(at: indexPath)
    }
    deleteAction.image = UIImage(named: "delete-icon")
    return [deleteAction]
  }
  
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    return options
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SwipeTableViewCell
    cell.delegate = self
    return cell
  }
  
  func updateModel(at indexPath: IndexPath) {
    
  }
}
