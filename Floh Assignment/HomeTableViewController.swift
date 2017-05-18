//
//  HomeTableViewController.swift
//  Floh Assignment
//
//  Created by 01HW934413 on 17/05/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    fileprivate var tweets = [Tweet]()
    
    private var fetchWebService : FetchTweetWebService!
    fileprivate var loadMoreTweets = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        initializeTableView()
        fetchTweets()
    }
    
    func initializeTableView () {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    

    func refresh(_ refreshControl: UIRefreshControl) {
        fetchTweets()
    }

    
    func fetchTweets() {
        fetchWebService = FetchTweetWebService(identifier: "initialLoad", delegate: self)
        fetchWebService.fetchTweets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tweets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        cell.tweetTextLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.twitterHandleLabel.text = tweet.handle
        
        
        if let image = ImageLoader.cache.object(forKey: tweet.imageUrl as AnyObject) as? Data{
            let cachedImage = UIImage(data: image)
            cell.profileImageView.image = cachedImage
        } else {
            let imageLoader = ImageLoader(delegate: self, indexPath: indexPath)
            imageLoader.imageFromUrl(urlString: tweet.imageUrl)
            cell.profileImageView.image = #imageLiteral(resourceName: "placeholder")
        }
        

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight  - (2.0 * scrollView.frame.size.height)) && loadMoreTweets {
            loadMoreTweets = false
            fetchWebService = FetchTweetWebService(identifier: "onScrolling", delegate: self)
            fetchWebService.fetchTweets(isNextResult: true)
        }
        
    }
    
}

extension HomeTableViewController: ImageLoaderProtocol {
    func imageLoaded(image: UIImage, forIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell {
            cell.profileImageView.image = image
        }
    }
}

extension HomeTableViewController: FetchTweetDelegate {
    func tweetsFetched(identifier: String, tweets: [Tweet]) {
        self.tweets = tweets
        tableView.reloadData()
        refreshControl?.endRefreshing()
        loadMoreTweets = true
    }
    
    func errorFetchingTweets(identifier: String, errorMessage: String) {
        print(errorMessage)
    }
    
    func tweetsFetchedOnScrolling(identifier: String, tweets: [Tweet]) {
        let initialCount = self.tweets.count
        let finalCount = initialCount + tweets.count
        var indexPaths = [IndexPath]()
        for item in initialCount..<finalCount {
            let indexPath = IndexPath(row: item, section: 0)
            indexPaths.append(indexPath)
        }
        
        self.tweets.append(contentsOf: tweets)
        tableView.insertRows(at: indexPaths, with: .bottom)
        loadMoreTweets = true
    }
}
