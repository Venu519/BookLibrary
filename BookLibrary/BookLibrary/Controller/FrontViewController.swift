//
//  FrontViewController.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 23/05/17.
//  Copyright © 2017 venu. All rights reserved.
//

import UIKit
import CoreData
import UPCarouselFlowLayout

class FrontViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var refreshControl: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var cache:NSCache<AnyObject, AnyObject>!
    var session: URLSession!
    var task: URLSessionDownloadTask!
    var dataSource = [BookObj]()
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            if self.dataSource.count > 0 {
                let book = self.dataSource[self.currentPage]
                self.titleLabel.text = book.title?.uppercased()
                self.subTitle.text = book.bookdesc?.uppercased()
            }
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = appDelegate.appCache
        
        getBooksList()
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        collectionView.collectionViewLayout = layout
        
        self.setupLayout()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FrontViewController.rotationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let revealViewController = self.revealViewController()
        revealViewController?.panGestureRecognizer()
        revealViewController?.tapGestureRecognizer()
        
        let revealButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "reveal-icon"), style: .plain, target: revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)))
        
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        
        // Do any additional setup after loading the view.
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2351517379, green: 0.09920636564, blue: 0.3827108145, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.title = "Library"
    }
    
    @objc fileprivate func rotationDidChange() {
        guard !orientation.isFlat else { return }
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let direction: UICollectionViewScrollDirection = UIDeviceOrientationIsPortrait(orientation) ? .horizontal : .vertical
        layout.scrollDirection = direction
        if currentPage > 0 {
            let indexPath = IndexPath(item: currentPage, section: 0)
            let scrollPosition: UICollectionViewScrollPosition = UIDeviceOrientationIsPortrait(orientation) ? .centeredHorizontally : .centeredVertically
            self.collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
        }
    }
    
    fileprivate func setupLayout() {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)
        rotationDidChange()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealToggle(_: UIBarButtonItem){
        
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let book = dataSource[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(named: "placeholder")
        
        //Download Image
        if (self.cache.object(forKey: book.bookId as AnyObject) != nil){
            print("Cached image used, no need to download it")
            cell.imageView?.image = self.cache.object(forKey: book.bookId as AnyObject) as? UIImage
        }else{
            // 3
            let bookUrl = book.bookAvatar!
            URLSession.shared.dataTask(with: NSURL(string: bookUrl)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    print(error)
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    let img:UIImage! = UIImage(data: data!)
                    self.cache.setObject(img, forKey: book.bookId as AnyObject)
                    cell.imageView?.image = img
                })
                
            }).resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = dataSource[(indexPath as NSIndexPath).row]
        let detailsVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailsVC.book = book
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    func getBooksList(){
        self.refreshControl?.startAnimating()
        let _ = taskForGetBooksList { (response, error) in
            func sendError(_ error: String) {
                performUIUpdatesOnMain {
                    let alert = UIAlertController(title: "Oops!!", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion:nil)
                    self.refreshControl?.stopAnimating()
                }
            }
            guard error == nil else {
                sendError("No Network. Please try after sometime.")
                return
            }
            let booksArray = response as! Array<AnyObject>
            self.dataSource.removeAll()
            for book in booksArray {
                self.save(book: book as! Dictionary<String, Any>)
            }
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
                self.refreshControl?.stopAnimating()
                self.currentPage = 0
            }
        }
    }
    
    func save(book: Dictionary<String, Any>) {
        let entityName = "BookObj"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let bookId = book["id"] as! String
        
        let fetchRequest:NSFetchRequest<BookObj> = BookObj.fetchRequest()
        let predicate = NSPredicate(format: "bookId == %@", bookId)
        fetchRequest.predicate = predicate
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            if fetchResults.count > 0 {
                dataSource.append(fetchResults.first!)
            }else{
                print("None")
                let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                        in: managedContext)!
                
                let bookObj = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as! BookObj
                
                bookObj.authorName = (book["author"] as? Dictionary<String,Any>!)?["name"] as? String
                bookObj.authorAvatar = (book["author"] as? Dictionary<String,Any>!)?["avatar"] as? String
                bookObj.title =  book["name"] as? String
                bookObj.bookdesc = book["description"] as? String
                bookObj.bookAvatar = book["cover"] as? String
                bookObj.bookId = book["id"] as? String
                bookObj.genre = (book["genre"] as? Dictionary<String,Any>!)?["name"] as? String
                bookObj.likes = book["likes"] as! Int64
                bookObj.isFavorite = false
                bookObj.excerpt = ((book["introduction"] as! Array<Dictionary<String,Any>>).first)?["content"] as? String
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                bookObj.publishDate = formatter.date(from: book["published"] as! String) as NSDate?
                do {
                    try managedContext.save()
                    dataSource.append(bookObj)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    func fetchDataForFavorites(isFavorites: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<BookObj> = BookObj.fetchRequest()
        if isFavorites {
            let predicate = NSPredicate(format: "isFavorite == %@", NSNumber.init(value: isFavorites))
            fetchRequest.predicate = predicate
        }
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            if fetchResults.count > 0 {
                self.dataSource.removeAll()
                for item in fetchResults {
                    dataSource.append(item)
                }
                collectionView.reloadData()
                var book = BookObj()
                if self.dataSource.count - 1 < self.currentPage {
                    book = self.dataSource[self.dataSource.count-1]
                }else{
                    book = self.dataSource[self.currentPage]
                }
                
                self.titleLabel.text = book.title?.uppercased()
                self.subTitle.text = book.bookdesc?.uppercased()
            }
        }
        catch{
            fatalError("Failed to fetch employees: \(error)")
        }
    }
}
