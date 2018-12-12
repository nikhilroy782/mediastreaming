//
//  PlayingQueueCell.swift
//  My Music
//
//  Created by ICON on 07/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class PlayingQueueCell: UITableViewCell {
    
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var queue_image: UIImageView!
    @IBOutlet weak var queue_name: UILabel!
    @IBOutlet weak var queue_artist: UILabel!
    @IBOutlet weak var img_equilizer: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
