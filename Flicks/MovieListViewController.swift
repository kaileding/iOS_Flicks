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

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var movieCollection: UICollectionView!
    var listOrGrid: Bool = false // false: list. true: grid
    let segmentedCtr = UISegmentedControl(items: ["List", "Grid"])
    
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var requestURL: String!
    var navBarTitle: String!
    
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
        self.movieCollection.register(UINib(nibName: "MovieBriefCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "movieCardCell")
        
        // set search bar clear button
        let textField = self.searchBar.value(forKey: "_searchField") as! UITextField
        textField.clearButtonMode = .whileEditing
        
        // set the navigation bar appearance
        self.segmentedCtr.sizeToFit()
        self.segmentedCtr.addTarget(self, action: #selector(switchLook), for: UIControlEvents.valueChanged)
        self.segmentedCtr.tintColor = UIColor.black
        self.segmentedCtr.selectedSegmentIndex = 0
        let segmentedBtn = UIBarButtonItem(customView: segmentedCtr)
        self.navigationItem.setRightBarButton(segmentedBtn, animated: true)
        
        self.navigationItem.title = self.navBarTitle
        if let navBar = self.navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(named: "rabbits")!, for: .default)
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 4
            navBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18),
                NSForegroundColorAttributeName : UIColor.black,
                NSShadowAttributeName : shadow
            ]
        }
        
        // set table and collection frame
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let tableWidth = self.movieTable.frame.size.width
        let tableOriginY = self.movieTable.frame.origin.y
        let tableHeight = (self.movieTable.frame.size.height - tabBarHeight!) - navBarHeight!
        let tableFrame = CGRect(x: 0.0, y: tableOriginY, width: tableWidth, height: tableHeight-20.0)
        self.movieTable.frame = tableFrame
        self.movieCollection.frame = tableFrame
        
        // switch between table and collection
        if listOrGrid {
            self.movieCollection.alpha = 1.0
            self.movieTable.alpha = 0.0
        } else {
            self.movieCollection.alpha = 0.0
            self.movieTable.alpha = 1.0
        }
        
        requestMovieList(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.warningView.center.y > 0 {
            self.warningView.center.y -= self.warningView.frame.size.height
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ****************************
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
        
        if imgUrl != nil {
            detailsView.imgUrl = "https://image.tmdb.org/t/p/w500"+imgUrl!
            detailsView.smallImgUrl = "https://image.tmdb.org/t/p/w45"+imgUrl!
            detailsView.largeImgUrl = "https://image.tmdb.org/t/p/original"+imgUrl!
        } else {
            detailsView.noImg = true
        }
        detailsView.movieDetails = result
        
        self.navigationController?.pushViewController(detailsView, animated: true)
    }
    
    
    // ****************************
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
        
        if listOrGrid {
            self.movieCollection.reloadData()
        } else {
            self.movieTable.reloadData()
        }
    }
    
    
    
    // ****************************
    // collection view delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        return self.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCardCell", for: indexPath) as! MovieBriefCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var result: NSDictionary!
        if searchActive {
            result = self.filtered[indexPath.row]
        } else {
            result = self.returnedData[indexPath.row]
        }
        
        if result != nil {
            let imgUrl = result["poster_path"] as? String
            let title = result["title"] as? String
            if imgUrl != nil {
                (cell as! MovieBriefCollectionViewCell).movieImage.setImageWith(
                    URLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342"+imgUrl!)!),
                    placeholderImage: UIImage(named: "video"),
                    success: { (imgRequest, imgResponse, img) in
                        // imgResponse is nil if the image is cached
                        if imgResponse != nil {
                            // print("Image was not cached, fade in image")
                            (cell as! MovieBriefCollectionViewCell).movieImage.alpha = 0.0
                            (cell as! MovieBriefCollectionViewCell).movieImage.image = img
                            UIView.animate(withDuration: 1.0, animations: {
                                (cell as! MovieBriefCollectionViewCell).movieImage.alpha = 1.0
                            })
                        } else {
                            // print("Image was cached so just update the image")
                            (cell as! MovieBriefCollectionViewCell).movieImage.image = img
                        }
                        
                    },
                    failure: nil)
                
            } else {
                (cell as! MovieBriefCollectionViewCell).movieImage.image = UIImage(named: "video")
            }
            (cell as! MovieBriefCollectionViewCell).movieTitle.text = title
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let detailsView = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        
        var result: NSDictionary!
        if searchActive {
            result = self.filtered[indexPath.row]
        } else {
            result = self.returnedData[indexPath.row]
        }
        let imgUrl = result["poster_path"] as? String
        
        if imgUrl != nil {
            detailsView.imgUrl = "https://image.tmdb.org/t/p/w500"+imgUrl!
            detailsView.smallImgUrl = "https://image.tmdb.org/t/p/w45"+imgUrl!
            detailsView.largeImgUrl = "https://image.tmdb.org/t/p/original"+imgUrl!
        } else {
            detailsView.noImg = true
        }
        detailsView.movieDetails = result
        
        self.navigationController?.pushViewController(detailsView, animated: true)
    }
    
    
    // ****************************
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
                        
                        if self.listOrGrid {
                            self.movieCollection.reloadData()
                        } else {
                            self.movieTable.reloadData()
                        }
                        refreshControl.endRefreshing()
                    }
                }
            }
        });
        task.resume()
    }
    
    func switchLook() {
        if self.segmentedCtr.selectedSegmentIndex == 0 {
            self.listOrGrid = false
            self.movieCollection.alpha = 0.0
            self.movieTable.alpha = 1.0
            self.movieTable.reloadData()
            self.movieTable.insertSubview(self.refreshControl, at: 0)
        } else {
            self.listOrGrid = true
            self.movieCollection.alpha = 1.0
            self.movieTable.alpha = 0.0
            self.movieCollection.reloadData()
            self.movieCollection.insertSubview(self.refreshControl, at: 0)
        }
    }

}


