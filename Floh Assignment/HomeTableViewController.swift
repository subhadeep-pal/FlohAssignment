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
    
    @IBOutlet var activityIndicatorView: UIView!
    @IBOutlet weak var activityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        fetchTweets()
    }
    
    override func viewDidLayoutSubviews() {
        initializeActivityIndicator()
    }
    
    private func initializeActivityIndicator() {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
        activityIndicatorView.frame = frame
        tableView.addSubview(activityIndicatorView)
    }
    
    private func initializeTableView () {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0, green: 132/255, blue: 180/255, alpha: 1)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    

    func refresh(_ refreshControl: UIRefreshControl) {
        fetchTweets()
    }

    
    private func fetchTweets() {
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
        return (self.tweets.count + 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == self.tweets.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadMoreCell", for: indexPath) as! LoadMoreTableViewCell
            if TwitterData.next_results_url != nil {
                cell.noMoreTweetsLabel.isHidden = true
                cell.activityIndicator.startAnimating()
            } else {
                cell.noMoreTweetsLabel.isHidden = false
                cell.activityIndicator.stopAnimating()
                cell.noMoreTweetsLabel.text = "Thats the end..."
            }
            return cell
        } else {
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
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight  - (2.0 * scrollView.frame.size.height)) && loadMoreTweets {
            loadMoreTweets = false
            fetchWebService = FetchTweetWebService(identifier: "onScrolling", delegate: self)
            fetchWebService.fetchTweets(isNextResult: true)
        }
        
    }
    
    fileprivate func showErrorAlert(message: String){
        let alertController = UIAlertController(title: "OOPS!!!", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            self.activityLabel.text = "Pull to try again..."
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
    
    func reachedEndOfTweets(identifier: String) {
        loadMoreTweets = false
    }
    
    func tweetsFetched(identifier: String, tweets: [Tweet]) {
        self.tweets = tweets
        tableView.reloadData()
        refreshControl?.endRefreshing()
        activityIndicatorView.isHidden = true
        loadMoreTweets = true
    }
    
    func errorFetchingTweets(identifier: String, errorMessage: String) {
        loadMoreTweets = true
        showErrorAlert(message: errorMessage)
    }
    
    func tweetsFetchedOnScrolling(identifier: String, tweets: [Tweet]) {
//        let initialCount = self.tweets.count
//        let finalCount = initialCount + tweets.count
//        var indexPaths = [IndexPath]()
//        for item in initialCount..<finalCount {
//            let indexPath = IndexPath(row: item, section: 0)
//            indexPaths.append(indexPath)
//        }
        
        self.tweets.append(contentsOf: tweets)
//        tableView.insertRows(at: indexPaths, with: .bottom) // View is flickering
        tableView.reloadData()
        loadMoreTweets = true
    }
}
