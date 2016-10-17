//
//  MovieListViewController.swift
//  Flicks
//
//  Created by DINGKaile on 10/15/16.
//  Copyright © 2016 myPersonalProjects. All rights reserved.
//

import UIKit
import AFNetworking
import LCLoadingHUD

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var requestURL: String!
    
    var returnedData: [NSDictionary] = []
    var numberOfMovies: Int = 0
    var searchActive: Bool = false
    var filtered: [NSDictionary] = []
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.refreshControl.addTarget(self, action: #selector(requestMovieList(_:)), for: UIControlEvents.valueChanged)
        self.movieTable.insertSubview(self.refreshControl, at: 0)
        self.movieTable.register(UINib(nibName: "MovieBriefTableViewCell", bundle: nil), forCellReuseIdentifier: "movieBriefCell")
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height
        let tableWidth = self.movieTable.frame.size.width
        let tableOriginY = self.movieTable.frame.origin.y
        let tableHeight = self.movieTable.frame.size.height - tabBarHeight!
        let tableFrame = CGRect(x: 0.0, y: tableOriginY, width: tableWidth, height: tableHeight)
        self.movieTable.frame = tableFrame
        
        let textField = self.searchBar.value(forKey: "_searchField") as! UITextField
        textField.clearButtonMode = .whileEditing
        
        requestMovieList(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.warningView.center.y > 0 {
            self.warningView.center.y -= self.warningView.frame.size.height
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // tableView delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        
        return self.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieBriefCell") as! MovieBriefTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var result: NSDictionary!
        if searchActive {
            result = self.filtered[indexPath.row] 
        } else {
            result = self.returnedData[indexPath.row]
        }
        
        if result != nil {
            let imgUrl = result["poster_path"] as? String
            let title = result["title"] as? String
            let overview = result["overview"] as? String
            if imgUrl != nil {
                (cell as! MovieBriefTableViewCell).movieImage.setImageWith(
                    URLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342"+imgUrl!)!),
                    placeholderImage: UIImage(named: "video"),
                    success: { (imgRequest, imgResponse, img) in
                        // imgResponse is nil if the image is cached
                        if imgResponse != nil {
                            // print("Image was not cached, fade in image")
                            (cell as! MovieBriefTableViewCell).movieImage.alpha = 0.0
                            (cell as! MovieBriefTableViewCell).movieImage.image = img
                            (cell as! MovieBriefTableViewCell).bkImage.image = img
                            UIView.animate(withDuration: 1.0, animations: {
                                (cell as! MovieBriefTableViewCell).movieImage.alpha = 1.0
                            })
                        } else {
                            // print("Image was cached so just update the image")
                            (cell as! MovieBriefTableViewCell).movieImage.image = img
                            (cell as! MovieBriefTableViewCell).bkImage.image = img
                        }
                        
                    },
                    failure: nil)
                
            } else {
                (cell as! MovieBriefTableViewCell).movieImage.image = UIImage(named: "video")
            }
            (cell as! MovieBriefTableViewCell).movieName.text = title
            (cell as! MovieBriefTableViewCell).movieIntro.text = overview
            (cell as! MovieBriefTableViewCell).bkImage.alpha = 0.0
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MovieBriefTableViewCell
        cell.bkImage.alpha = 0.0
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MovieBriefTableViewCell
        cell.bkImage.alpha = 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailsView = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        
        var result: NSDictionary!
        if searchActive {
            result = self.filtered[indexPath.row]
        } else {
            result = self.returnedData[indexPath.row]
        }
        let imgUrl = result["poster_path"] as? String
        
        detailsView.imgUrl = "https://image.tmdb.org/t/p/w500"+imgUrl!
        detailsView.smallImgUrl = "https://image.tmdb.org/t/p/w45"+imgUrl!
        detailsView.largeImgUrl = "https://image.tmdb.org/t/p/original"+imgUrl!
        detailsView.movieDetails = result
        
        self.navigationController?.pushViewController(detailsView, animated: true)
    }
    
    
    // search bar delegate functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = false
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchActive = false
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filtered = self.returnedData.filter({ (result) -> Bool in
            let title = result["title"] as! String
            //let range = title.rangeOfString(searchText, options: NSString.CompareOptions.CaseInsensitiveSearch)
            let range = title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            return (range != nil)
        })
        self.searchActive = true
        if searchText == "" {
            self.searchActive = false
        }
        self.movieTable.reloadData()
    }
    
    
    // helper functions
    func requestMovieList(_ refreshControl: UIRefreshControl) {
        // display HUD before the request is made
        LCLoadingHUD.showLoading("Loading", in: self.view)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: (self.requestURL + apiKey))
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if error != nil {
                if self.warningView.center.y < 0 {
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                        self.warningView.center.y += self.warningView.frame.size.height
                        }, completion: nil)
                    UIView.animate(withDuration: 1.0, delay: 1.2, options: [.curveEaseInOut], animations: {
                        self.warningView.center.y -= self.warningView.frame.size.height
                        }, completion: nil)
                }
                // hide HUD after network request comes back
                LCLoadingHUD.hide(in: self.view)
                refreshControl.endRefreshing()
                
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        //NSLog("response: \(responseDictionary)")
                        if let results = responseDictionary["results"] as? NSArray {
                            self.returnedData = results as! [NSDictionary]
                            self.numberOfMovies = results.count
                        }
                        // hide HUD after network request comes back
                        LCLoadingHUD.hide(in: self.view)
                        
                        self.movieTable.reloadData()
                        refreshControl.endRefreshing()
                    }
                }
            }
        });
        task.resume()
    }

}


