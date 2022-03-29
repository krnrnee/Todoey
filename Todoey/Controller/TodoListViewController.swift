//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    //let itemArray: [ItemCell] = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    //var itemArray: [ItemCell] = []
    var itemArray: [String] = []
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    func loadItems() {
        //        addItem(title: "Find Mike")
        //        addItem(title: "Buy Eggos")
        //        addItem(title: "Destroy Demogorgon")
        if let items = defaults.array(forKey: K.todoListKey) as? [String] {
            itemArray = items
        }
    }
    
    func createItem (title: String) -> ItemCell {
        let newItem = ItemCell(title: title)
        return newItem
    }
    
    func addItem (title: String) {
        //itemArray.append(createItem(title: title))
        itemArray.append(title)
    }
    
    //MARK: - <Tableview Datasource Methods>
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        //cell.textLabel?.text = item.title
        cell.textLabel?.text = item
        
        return cell
    }
    
    //MARK: - <Tableview Datasource Methods>
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - <Add New Items>
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //let newItem = self.createItem(title: textField.text ?? "")
            //self.itemArray.append(newItem)
            if let safeText = textField.text {
                self.addItem(title: safeText)
                print(self.itemArray)
                self.defaults.set(self.itemArray, forKey: K.todoListKey)
                self.tableView.reloadData()
            } else {
                print("New item textfield is nil")
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}

