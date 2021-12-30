//
//  ItemsViewController.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemsViewController: SwipeTableViewController {
  private let realm = try! Realm()
  private var itemsArray: Results<Item>?
  var selectedCategory: Category? {
    didSet {
      loadItems()
    }
  }
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let navBar = navigationController?.navigationBar else {
      fatalError("Navigation controller does not exist")
    }
    if let colorHex = selectedCategory?.color {
      title = selectedCategory!.name
      if let navBarColor = UIColor(hexString: colorHex) {
        let contrastColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.backgroundColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
        navBar.tintColor = contrastColor
        navigationItem.rightBarButtonItem?.tintColor = contrastColor
        searchBar.backgroundColor = navBarColor
        searchBar.searchTextField.backgroundColor = FlatWhite()
        searchBar.searchBarStyle = .minimal
      }
    }
  }
  
  // MARK: - TableView Datasource Methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemsArray?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    if let item = itemsArray?[indexPath.row] {
      cell.textLabel?.text = item.name
      cell.accessoryType = item.done ? .checkmark : .none
      if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemsArray!.count)) {
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
      }
    }
    return cell
  }
  
  // MARK: - TableView Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let item = itemsArray?[indexPath.row] {
      do {
        try realm.write({
          item.done = !item.done
        })
      } catch {
        let nsError = error as NSError
        fatalError("Error updating items \(nsError), \(nsError.userInfo)")
      }
    }
    tableView.reloadData()
  }
  
  // MARK: - Data Manipulation Methods

  private func loadItems() {
    itemsArray = selectedCategory?.items.sorted(byKeyPath: K.itemFields.dateField, ascending: true)
    tableView.reloadData()
  }
  
  override func updateModel(at indexPath: IndexPath) {
    if let item = itemsArray?[indexPath.row] {
      do {
        try realm.write({
          realm.delete(item)
        })
      } catch {
        let nsError = error as NSError
        fatalError("Error deleting items \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: - Add New Item
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textField = UITextField()
    let alert = UIAlertController(title: "Добавить новый пункт", message: "", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Добавить", style: .default) { action in
      if let currentCategory = self.selectedCategory {
        do {
          try self.realm.write {
            let newItem = Item()
            newItem.name = textField.text!
            currentCategory.items.append(newItem)
            self.realm.add(newItem)
          }
        } catch {
          let nsError = error as NSError
          fatalError("Error saving new item \(nsError), \(nsError.userInfo)")
        }
      }
      self.tableView.reloadData()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
    
    alert.addTextField { alertTextField in
      alertTextField.placeholder = "Добавить пункт"
      textField = alertTextField
    }
    
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - SearchBar Delegate Methods

extension ItemsViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    itemsArray = itemsArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: K.itemFields.dateField, ascending: true)
    tableView.reloadData()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
      loadItems()
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
}
