//
//  MenuViewController.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 23/05/17.
//  Copyright © 2017 venu. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var list:[String] = [String]()
    var presentedRow: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        list = ["Favorites","Library"]
        tableView.delegate = self
        tableView.dataSource = self
        presentedRow = 1
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2351517379, green: 0.09920636564, blue: 0.3827108145, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.title = "Menu"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (nil == cell)
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.text = NSLocalizedString( list[indexPath.row], tableName: nil, comment: "" )
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewController = self.revealViewController()
        let row = indexPath.row
        let frontViewControl = ((revealViewController?.frontViewController as! UINavigationController).viewControllers.first) as! FrontViewController
        frontViewControl.title = list[indexPath.row]
        if list[indexPath.row] == "Favorites" {
            frontViewControl.fetchDataForFavorites(isFavorites: true)
        }else{
            frontViewControl.fetchDataForFavorites(isFavorites: false)
        }
        revealViewController?.setFrontViewPosition(.left, animated: true)
        presentedRow = row;
    }
}
