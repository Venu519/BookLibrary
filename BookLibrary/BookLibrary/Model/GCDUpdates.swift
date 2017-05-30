//
//  GCDUpdates.swift
//  BookLibrary
//
//  Created by Venugopal Reddy Devarapally on 22/05/17.
//  Copyright © 2017 Venugopal Reddy Devarapally. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
