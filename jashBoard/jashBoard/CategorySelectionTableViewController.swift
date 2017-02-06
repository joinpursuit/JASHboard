//
//  CategorySelectionTableViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit

class CategorySelectionTableViewController: UITableViewController {

    var categories = ["Animals", "Beach Days", "Flowers & Plants"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Categories"
        self.view.backgroundColor = .blue
        self.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.cellIdentifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.cellIdentifier, for: indexPath) as! CategoryTableViewCell

        cell.categoryTitleLabel.text = categories[indexPath.row]
        
        return cell
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navController = self.navigationController{
            let categoryController = CategoryPhotosCollectionViewController(collectionViewLayout: .init())
            categoryController.title = categories[indexPath.row]
            navController.pushViewController(categoryController, animated: true)
        }
    }


}
