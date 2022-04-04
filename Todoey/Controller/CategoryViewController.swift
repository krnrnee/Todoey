//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Karen Turner on 3/30/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
        
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        navBar.backgroundColor = FlatSkyBlue()
        
        navBar.tintColor = ContrastColorOf(navBar.backgroundColor ?? .white, returnFlat: true)
        
         navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor ?? .white]
        
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories?[indexPath.row]
 
        cell.textLabel?.text = category?.name ?? "Add your first category"
        
        if let hexColor = category?.hexColor {
            if hexColor != "" {
                cell.backgroundColor = UIColor(hexString: hexColor)
            } else {
                cell.backgroundColor = UIColor.randomFlat()
            }
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.toDoListSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        } else {
            print("No index path")
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func addCategory (name: String) {
        let newCategory = Category()
        newCategory.name = name
        newCategory.hexColor = UIColor.randomFlat().hexValue()
        saveCategory(category: newCategory)
        tableView.reloadData()
    }
    
    func saveCategory(category: Category) {
        
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving category to Realm DB")
        }
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
     }
    
    //MARK: - Delete Data From Swipe Cell
    
    func deleteCategory (category: Category) {
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("Error deleting item")
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        self.deleteCategory(category: (self.categories?[indexPath.row])!)
 
    }

    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let safeText = textField.text {
                self.addCategory(name: safeText)
            } else {
                print("New Category textfield is nil")
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
