//
//  BookObj+CoreDataProperties.swift
//  
//
//  Created by Venugopal Reddy Devarapally on 29/05/17.
//
//

import Foundation
import CoreData


extension BookObj {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookObj> {
        return NSFetchRequest<BookObj>(entityName: "BookObj")
    }

    @NSManaged public var title: String?
    @NSManaged public var bookdesc: String?
    @NSManaged public var authorName: String?
    @NSManaged public var authorAvatar: String?
    @NSManaged public var bookAvatar: String?
    @NSManaged public var bookId: String?
    @NSManaged public var genre: String?
    @NSManaged public var likes: Int64
    @NSManaged public var publishDate: NSDate?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var excerpt: String?

}
