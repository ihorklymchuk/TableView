//
//  ViewController.swift
//  TableView
//
//  Created by Ihor Klymchuk on 11/08/2022.
//

import UIKit
import RealmSwift

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
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
    
//    extension ViewController: UISearchBarDelegate {
//     
//        
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            
//            let request: NSFetchRequest<Item> = Item.fetchRequest()
//            
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//            
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//            
//            loadItems(with: request)
//        }
//        
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            if searchBar.text?.count == 0 {
//                loadItems()
//                DispatchQueue.main.async {
//                    searchBar.resignFirstResponder()
//                }
//            }
//        }
//    }
