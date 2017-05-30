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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let row = indexPath.row
        
        if (nil == cell)
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel?.text = NSLocalizedString( list[indexPath.row], tableName: nil, comment: "" )
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
        let revealViewController = self.revealViewController()
        // selecting row
        let row = indexPath.row
        let frontViewControl = ((revealViewController?.frontViewController as! UINavigationController).viewControllers.first) as! FrontViewController
        frontViewControl.title = list[indexPath.row]
        if list[indexPath.row] == "Favorites" {
            frontViewControl.fetchDataForFavorites(isFavorites: true)
        }else{
            frontViewControl.fetchDataForFavorites(isFavorites: false)
        }
        revealViewController?.setFrontViewPosition(.left, animated: true)
        
        // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
        // we'll just set position and return
        
        // otherwise we'll create a new frontViewController and push it with animation
        
//        UIViewController *newFrontController = nil;
//        
//        if (row == 0)
//        {
//            newFrontController = [[FrontViewController alloc] init];
//        }
//            
//        else if (row == 1)
//        {
//            newFrontController = [[MapViewController alloc] init];
//        }
//        
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
//        [revealController pushFrontViewController:navigationController animated:YES];
//        
        presentedRow = row;  // <- store the presented row
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
