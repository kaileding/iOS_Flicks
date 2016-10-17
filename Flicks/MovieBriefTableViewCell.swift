//
//  MovieBriefTableViewCell.swift
//  Flicks
//
//  Created by DINGKaile on 10/15/16.
//  Copyright © 2016 myPersonalProjects. All rights reserved.
//

import UIKit

class MovieBriefTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bkImage: UIImageView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieIntro: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
