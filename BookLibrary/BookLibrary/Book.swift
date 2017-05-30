//
//  Book.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 22/05/17.
//  Copyright © 2017 venu. All rights reserved.
//

import UIKit
import os.log

class Book: NSObject, NSCoding {
    var bookTitle: String!
    var bookDescription: String!
    var author: String!
    var authorAvatar: String!
    var bookAvatar: String!
    var bookId: String!
    var publishDate: Date!
    var genre: String!
    var bookLikes: Int!
    var isBookFavorite: Bool!
    
    var bookDict: Dictionary<String, Any>!
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("books")
    
    struct PropertyKey {
        static let bookDict = "bookDict"
        static let isBookFavorite = "isBookFavorite"
    }
    
    override init() {
        super.init()
    }
    
    init?(bookObj: Dictionary<String, Any>, isFav: Bool) {
        self.author = (bookObj["author"] as? Dictionary<String,Any>!)?["name"] as! String
        self.authorAvatar = (bookObj["author"] as? Dictionary<String,Any>!)?["avatar"] as! String
        self.bookTitle =  bookObj["name"] as! String
        self.bookDescription = bookObj["description"] as! String
        self.bookAvatar = bookObj["cover"] as! String
        self.bookId = bookObj["id"] as! String
        self.genre = (bookObj["genre"] as? Dictionary<String,Any>!)?["name"] as! String
        self.bookLikes = bookObj["likes"] as! Int
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        self.publishDate = formatter.date(from: bookObj["published"] as! String)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bookDict, forKey: PropertyKey.bookDict)
        aCoder.encode(isBookFavorite, forKey: PropertyKey.isBookFavorite)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let bookDictDecoded = aDecoder.decodeObject(forKey: PropertyKey.bookDict) as? Dictionary<String, Any>
        let isBookFavoriteDecoded = aDecoder.decodeObject(forKey: PropertyKey.isBookFavorite) as! Bool
        self.init(bookObj: bookDictDecoded!, isFav: isBookFavoriteDecoded)
    }
}
