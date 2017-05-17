//
//  Tweet.swift
//  Floh Assignment
//
//  Created by Subhadeep Pal on 17/05/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    let name: String
    let text: String
    let imageUrl: URL
    
    init(name: String, text: String, imageUrl: String) {
        self.name = name
        self.text = text
        self.imageUrl = URL(string: imageUrl)!
    }

}
