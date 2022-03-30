//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Karen Turner on 3/30/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var catArray = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }

    // MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = catArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellID, for: indexPath)
        cell.textLabel?.text = category.name

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    //MARK: - Data Manipulation Methods
    
    func addCategory (name: String) {
        let newCategory = Category(context: context)
        newCategory.name = name
        catArray.append(newCategory)
        saveCategories()
        tableView.reloadData()
    }
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context")
        }
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            catArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching from context \(error)")
        }
    }
    
    func deleteCategory (row: Int) {
        context.delete(catArray[row])
        catArray.remove(at: row)
        saveCategories()
        tableView.reloadData()
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
