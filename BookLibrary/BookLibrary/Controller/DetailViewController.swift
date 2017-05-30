//
//  DetailViewController.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 24/05/17.
//  Copyright © 2017 venu. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var bookAvatar: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDesc: UILabel!
    @IBOutlet weak var bookExcerpt: UITextView!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    var book = BookObj()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        bookAvatar.imageFromServerURL(urlString: book.bookAvatar!)
        bookTitle.text = book.title
        bookDesc.text = book.bookdesc
        authorAvatar.imageFromServerURL(urlString: book.authorAvatar!)
        authorName.text = book.authorName
        bookExcerpt.text = book.excerpt
        updateFavBtn()
        authorAvatar.layer.cornerRadius = max(authorAvatar.frame.size.width, authorAvatar.frame.size.height) / 2
        // Do any additional setup after loading the view.
    }
    
    func updateFavBtn(){
        if book.isFavorite {
            favBtn.setImage(UIImage.init(named: "favoritesSelected"), for: .normal)
        }else{
            favBtn.setImage(UIImage.init(named: "favorites"), for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favBtnAction(_ sender: Any) {
        save(isFavorite: !book.isFavorite)
    }
    
    func save(isFavorite: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<BookObj> = BookObj.fetchRequest()
        let predicate = NSPredicate(format: "bookId == %@", book.bookId!)
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            if fetchResults.count > 0 {
                let bookObj = fetchResults.first
                bookObj?.isFavorite = isFavorite
                do {
                    try managedContext.save()
                    book = bookObj!
                    updateFavBtn()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        catch{
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}
