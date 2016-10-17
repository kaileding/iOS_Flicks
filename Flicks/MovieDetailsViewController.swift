//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by DINGKaile on 10/16/16.
//  Copyright © 2016 myPersonalProjects. All rights reserved.
//

import UIKit
import AFNetworking
import LCLoadingHUD

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topOffsetView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bottomOffsetView: UIView!
    @IBOutlet weak var warningVIew: UIView!
    
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var noImg: Bool = false
    
    var imgUrl: String!
    var smallImgUrl: String!
    var largeImgUrl: String!
    
    var movieDetails: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the movieImage frame
        let imgWidth = self.movieImage.frame.size.width
        let imgHeight = self.movieImage.frame.size.height - (self.navigationController?.navigationBar.frame.size.height)!
        let imgFrame = CGRect(x: 0.0, y: 0.0, width: imgWidth, height: imgHeight)
        self.movieImage.frame = imgFrame
        
        // set the navigation bar appearance
        self.navigationItem.title = "Film Details"
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
        
        
        // set top offset filling views
        let scrollViewXpos = self.scrollView.frame.origin.x
        let scrollViewYpos = self.scrollView.frame.origin.y
        let scrollViewWidth = self.scrollView.frame.size.width
        let scrollViewHeight = self.scrollView.frame.size.height
        let topFrame = CGRect(x: scrollViewXpos, y: scrollViewYpos, width: scrollViewWidth, height: scrollViewHeight*0.6)
        self.topOffsetView.frame = topFrame
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.warningVIew.center.y > 0 {
            self.warningVIew.center.y -= self.warningVIew.frame.size.height
        }
        // set movie description background image
        fancyImgLoad()
        
        // set movie description texts
        self.movieName.text = self.movieDetails["title"] as? String
        let dateInNumber: String = self.movieDetails["release_date"] as! String
        self.dateLabel.text = translateDate(dateInNumber)
        self.descriptionLabel.text = self.movieDetails["overview"] as? String
        
        // resize card
        self.descriptionLabel.sizeToFit()
        let desLabelYpos = self.descriptionLabel.frame.origin.y
        let desLabelHeight = self.descriptionLabel.frame.size.height
        let cardXpos = self.cardView.frame.origin.x
        let cardFitYpos = self.topOffsetView.frame.size.height + 10.0
        let cardWidth = self.cardView.frame.size.width
        let cardFitHeight = (desLabelYpos + desLabelHeight) + 10.0
        let cardFitFrame = CGRect(x: cardXpos, y: cardFitYpos, width: cardWidth, height: cardFitHeight)
        self.cardView.frame = cardFitFrame
        
        // set bottom offset filling view position
        let bottomViewYpos = (cardFitYpos + cardFitHeight) + 20.0
        let bottomBarHeight = (tabBarController?.tabBar.frame.size.height)! + (self.navigationController?.navigationBar.frame.size.height)!
        self.bottomOffsetView.frame = CGRect(x: cardXpos, y: bottomViewYpos, width: cardWidth, height: bottomBarHeight)
        
        // set the content size of scrollview
        let totalContentHeight = (bottomViewYpos + bottomBarHeight) + 10.0
        self.scrollView.contentSize = CGSize(width: cardWidth, height: totalContentHeight)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // helper functions
    func translateDate(_ dateNum: String) -> String {
        var dateRes: String = ""
        let dateComp = dateNum.components(separatedBy: "-")
        let year: String = dateComp[0]
        let monthNum: Int = Int(dateComp[1])!
        let dateFormatter: DateFormatter = DateFormatter()
        let monthName: String = dateFormatter.monthSymbols[monthNum-1]
        let day: String = dateComp[2]
        dateRes = monthName + " " + day + ", " + year
        
        return dateRes
    }

    func fancyImgLoad() {
        if noImg {
            self.movieImage.image = UIImage(named: "video")
        } else {
            self.movieImage.setImageWith(
                URLRequest(url: URL(string: self.smallImgUrl)!),
                placeholderImage: UIImage(named: "video"),
                success: { (smallImgRequest, smallImgResponse, smallImg) in
                    // smallImgResponse will be nil if the smallImg is already in cache
                    self.movieImage.alpha = 0.0
                    self.movieImage.image = smallImg
                    
                    UIView.animate(
                        withDuration: 0.5,
                        animations: {
                            self.movieImage.alpha = 1.0
                        },
                        completion: { (success) -> Void in
                            // one request per ImageView at a time
                            self.movieImage.setImageWith(
                                URLRequest(url: URL(string: self.largeImgUrl)!),
                                placeholderImage: smallImg,
                                success: { (largeImgRequest, largeImgResponse, largeImg) in
                                    self.movieImage.image = largeImg
                                }, failure: nil)
                    })
                },
                failure: { (smallImgRequest, smallImgResponse, err) in
                    if self.warningVIew.center.y < 0 {
                        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                            self.warningVIew.center.y += self.warningVIew.frame.size.height
                            }, completion: nil)
                        UIView.animate(withDuration: 1.0, delay: 1.2, options: [.curveEaseInOut], animations: {
                            self.warningVIew.center.y -= self.warningVIew.frame.size.height
                            }, completion: nil)
                    }
            })
        }
    }
}
