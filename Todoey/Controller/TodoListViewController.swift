//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.appendingPathComponent)
 
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var itemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath)
         
        loadItems()
    }
        
    //MARK: - <Tableview Datasource Methods>
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = item.title
        
        //Ternary operator
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done  ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - <Tableview Datasource Methods>
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - <Add New Items>
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let safeText = textField.text {
                self.addItem(title: safeText)
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
    
    //MARK: - <Data Manipulation Methods>
    
    func addItem (title: String) {
        let newItem = Item(context: context)
        newItem.title = title
        newItem.done = false
        itemArray.append(newItem)
        saveItems()
        tableView.reloadData()
    }

    func saveItems() {
        
        do {
            try context.save()
         } catch {
             print("Error saving context")
         }
    }
    
    func loadItems() {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func deleteItem (row: Int) {
        context.delete(itemArray[row])
        itemArray.remove(at: row)
        saveItems()
        tableView.reloadData()
    }
}

