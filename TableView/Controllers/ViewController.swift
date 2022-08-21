//
//  ViewController.swift
//  TableView
//
//  Created by Ihor Klymchuk on 11/08/2022.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ViewController: UITableViewController  {
    
    let realm = try! Realm()

    var todoItemsArray: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Preferred Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }} catch {
                    print("Error saving the item: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type in new item here"
            textField = alertTextField
        }
            
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
    }
    
    
    // MARK - Model Manipulation Mathods

    func loadItems() {
        
        todoItemsArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
        }
    

    
    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItemsArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let item = todoItemsArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItemsArray?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error while updating: \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}



    
    //MARK: Search Bar Methods
    
    extension ViewController: UISearchBarDelegate {
     
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

            todoItemsArray = todoItemsArray?.filter("title CONTAINS [cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
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

    //MARK: Swipe Cell Delegate Methods

extension ViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if let itemToBeDeleted = self.todoItemsArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(itemToBeDeleted)
                    }
                    
                } catch {
                    print("Error while deleting an item: \(error)")
                }
            }
        }
        
        deleteAction.image = UIImage(named: "trash-circle")

        return [deleteAction]
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}

