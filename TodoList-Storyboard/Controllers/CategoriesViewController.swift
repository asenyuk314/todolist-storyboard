//
//  CategoriesViewController.swift
//  TodoList-Storyboard
//
//  Created by Александр Сенюк on 30.12.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesViewController: SwipeTableViewController {
  lazy private var realm = try! Realm()
  private var categories: Results<Category>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCategories()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let navBar = navigationController?.navigationBar else {
      fatalError("Navigation controller does not exist")
    }
    navBar.backgroundColor = .systemBlue
    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navBar.tintColor = .white
  }
  
  // MARK: - TableView Datasource Methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    cell.textLabel?.text = categories?[indexPath.row].name ?? ""
    if let color = UIColor(hexString: categories?[indexPath.row].color ?? UIColor.systemBlue.hexValue() ) {
      cell.backgroundColor = color
      cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
    }
    return cell
  }
  
  // MARK: - Data Manipulation Methods
  
  private func loadCategories() {
    categories = realm.objects(Category.self)
    tableView.reloadData()
  }
  
  private func saveCategories(category: Category) {
    do {
      try realm.write({
        realm.add(category)
      })
      tableView.reloadData()
    } catch {
      let nsError = error as NSError
      fatalError("Error saving categories \(nsError), \(nsError.userInfo)")
    }
  }
  
  override func updateModel(at indexPath: IndexPath) {
    if let categoryForDeletion = self.categories?[indexPath.row] {
      do {
        try self.realm.write({
          categoryForDeletion.items.forEach { item in
            self.realm.delete(item)
          }
          self.realm.delete(categoryForDeletion)
        })
      } catch {
        let nsError = error as NSError
        fatalError("Error deleting category \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: - Add New Categories
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textField = UITextField()
    let alert = UIAlertController(title: "Добавить новую категорию", message: "", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Добавить", style: .default) { action in
      DispatchQueue.main.async {
        let newCategory = Category()
        newCategory.name = textField.text!
        newCategory.color = UIColor.randomFlat().hexValue()
        self.saveCategories(category: newCategory)
      }
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
    
    alert.addTextField { alertTextField in
      alertTextField.placeholder = "Добавить категорию"
      textField = alertTextField
    }
    
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - TableView Delegate Methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: K.itemsSegue, sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == K.itemsSegue {
      let destinationVC = segue.destination as! ItemsViewController
      if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categories?[indexPath.row]
      }
    }
  }
}
