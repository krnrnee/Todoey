//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var items: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath)
        
        searchBar.delegate = self
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        navBar.backgroundColor = UIColor(hexString: selectedCategory?.hexColor ?? FlatSkyBlue().hexValue())
        navBar.tintColor = ContrastColorOf(navBar.backgroundColor ?? .white, returnFlat: true)
        
        title = selectedCategory?.name
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor ?? .white]
         
        searchBar.barTintColor = navBar.backgroundColor
        searchBar.searchTextField.backgroundColor = .white
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //Set color
            let numRows = items?.count ?? 1
            let colorPerc: CGFloat = CGFloat(indexPath.row) / CGFloat(numRows) * 0.7
            print (colorPerc, indexPath.row, numRows)
            let color = UIColor(hexString: selectedCategory?.hexColor ?? FlatSkyBlue().hexValue())
            cell.backgroundColor = color?.darken(byPercentage: colorPerc)
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor ?? .white, isFlat:true)
            
            //Ternary operator
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done  ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Add your first item"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print ("Error updating selected item")
            }
        }
        
        
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
    
    //MARK: - Data Manipulation Methods
    
    func addItem (title: String) {
        
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = title
                    newItem.done = false
                    currentCategory.items.append(newItem)
                }
            } catch {
                print ("Error adding item")
            }
        }
        
        tableView.reloadData()
    }
    
    func loadItems() {
        
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Items
    
    func deleteItem (item: Item) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Error deleting item")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        self.deleteItem(item: (self.items?[indexPath.row])!)
 
    }

}

//MARK: - SearchBar Delegate extension

extension TodoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Searching")
        
        items = items?.filter(K.searchTitleFormat, searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: true)
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

