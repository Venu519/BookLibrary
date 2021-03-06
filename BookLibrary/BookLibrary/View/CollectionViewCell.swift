//
//  CollectionViewCell.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 24/05/17.
//  Copyright © 2017 venu. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    static let identifier = "collectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = max(self.frame.size.width, self.frame.size.height) / 2
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor(red: 119.0/255.0, green: 99.0/255.0, blue: 189.0/255.0, alpha: 1.0).cgColor
        // Initialization code
    }
}
