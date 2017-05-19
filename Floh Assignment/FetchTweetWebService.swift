//
//  FetchTweetManager.swift
//  Floh Assignment
//
//  Created by 01HW934413 on 17/05/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

protocol FetchTweetDelegate {
    func tweetsFetched(identifier: String, tweets: [Tweet])
    func tweetsFetchedOnScrolling(identifier: String, tweets: [Tweet])
    func errorFetchingTweets(identifier: String, errorMessage: String)
    func reachedEndOfTweets(identifier: String)
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
    
    
    func fetchTweets(isNextResult: Bool = false) {
        
        var urlString = "\(fetchURLString)"
        if isNextResult {
            //Get URL for next results
            if let next_results_url = TwitterData.next_results_url {
                urlString += next_results_url
            } else {
                // Next results not available
                //End Scroll
                self.delegate.reachedEndOfTweets(identifier: self.identifier)
                return
            }
        } else {
            //First Load URL
            urlString += "?q=%40FlohNetwork%20OR%20from%3AFlohNetwork&count=6"
//            urlString += "?q=%40KKRiders%20OR%20from%3AKKRiders&count=6" //Because FlohNetwork has less tweets
        }
        
        print(urlString)
        let url = URL(string: urlString)

        var urlRequest = URLRequest(url: url!)
        
        urlRequest.addValue("Bearer AAAAAAAAAAAAAAAAAAAAADLH0gAAAAAA9WgpnSZG8WsGEtTFr5EEreR0j1M%3D3iwv9ZW1pxECsfXQ6jRkWIdwsEXSF051uVYf1fLF5UPVDnuKHK", forHTTPHeaderField: "Authorization")
        
        let urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                // Service Call Failed
                DispatchQueue.main.async { [unowned self] in
                    self.delegate.errorFetchingTweets(identifier: self.identifier, errorMessage: "Service Call Failed \(error.localizedDescription)")
                }
            } else if let response = response as? HTTPURLResponse {
                
                // HTTP Response with proper Status Code
                if response.statusCode == 200 {
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String,Any>
                        let statuses = responseDict["statuses"] as! [Dictionary<String,Any>]
                        var responseTweets = [Tweet]()
                        for status in statuses {
                            let text = status["text"] as! String
                            let user = status["user"] as! Dictionary<String,Any>
                            let screen_name = user["screen_name"] as! String
                            let name = user["name"] as! String
                            let profile_image_url_https = user["profile_image_url_https"] as! String
                            
                            let tweet = Tweet(name: name, handle: screen_name, text: text, imageUrl: profile_image_url_https)
                            responseTweets.append(tweet)
                        }
                        let search_metadata = responseDict["search_metadata"] as! Dictionary<String,Any>
                        let next_results = search_metadata["next_results"] as? String
                        TwitterData.next_results_url = next_results
                        
                        DispatchQueue.main.async { [unowned self] in
                            if isNextResult{
                                self.delegate.tweetsFetchedOnScrolling(identifier: self.identifier, tweets: responseTweets)
                                return
                            } else {
                                self.delegate.tweetsFetched(identifier: self.identifier, tweets: responseTweets)
                                return
                            }
                        }
                    } catch {
                        // Error in parsing JSON
                        DispatchQueue.main.async { [unowned self] in
                            self.delegate.errorFetchingTweets(identifier: self.identifier, errorMessage: "JSON Parsing Failed")
                        }
                    }
                } else {
                    // INot OK Response
                    DispatchQueue.main.async { [unowned self] in
                        self.delegate.errorFetchingTweets(identifier: self.identifier, errorMessage: "Invalid Service Call Code : \(response.statusCode)")
                    }
                }
            }
        }
        
        dataTask.resume()
        
    }
    
}
