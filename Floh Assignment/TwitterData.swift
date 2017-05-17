//
//  TwitterData.swift
//  Floh Assignment
//
//  Created by 01HW934413 on 17/05/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

class TwitterData: NSObject {

    private let consumerKey = "5FQzHEk0HBEGv5r5pC3wBlXGX"
    private let consumerSecret = "De8kfSjDqB0s7vl422p4lQTSH5UM02GaOHnOWbA1R8smFCAP92"
    
    private var authorizationString : String {
        let authString = "\(consumerKey):\(consumerSecret)"
        let encodedAuthString = authString.data(using: .utf8)
        
        return "Basic \(encodedAuthString!.base64EncodedString())"
    }
    
    static var next_results_url:String? = nil
}
