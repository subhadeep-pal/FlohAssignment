//
//  FetchTweetManager.swift
//  Floh Assignment
//
//  Created by 01HW934413 on 17/05/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

protocol FetchTweetDelegate {
    func tweetsFetched()
    func tweetsFetchedOnScrolling()
    func errorFetchingTweets()
}

class FetchTweetWebService: NSObject {
    
    let delegate : FetchTweetDelegate
    let identifier : String
    
    init(identifier: String, delegate: FetchTweetDelegate) {
        self.delegate = delegate
        self.identifier = identifier
    }
    
    var fetchURLString : String {
        let apiListpath = Bundle.main.path(forResource: "API", ofType: "plist")!
        let APIDict = NSDictionary(contentsOfFile: apiListpath)
        let urlString = APIDict?.value(forKey: "Fetch Tweets") as! String
        return urlString
    }
    
    
    func fetchTweets(nextResultsParameter: String = "?q=%40FlohNetwork%20OR%20from%3AFlohNetwork&count=6") {
        
        let urlString = "\(fetchURLString)\(nextResultsParameter)"
        let url = URL(string: urlString)

        var urlRequest = URLRequest(url: url!)
        
        urlRequest.addValue("Bearer AAAAAAAAAAAAAAAAAAAAADLH0gAAAAAA9WgpnSZG8WsGEtTFr5EEreR0j1M%3D3iwv9ZW1pxECsfXQ6jRkWIdwsEXSF051uVYf1fLF5UPVDnuKHK", forHTTPHeaderField: "Authorization")
        
        let urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        
        dataTask.resume()
        
    }
    
}
