//
//  PlayingCell.swift
//  My Music
//
//  Created by ICON on 27/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class PlayingCell: UITableViewCell {
    
    @IBOutlet weak var song_image: UIImageView!
    @IBOutlet weak var song_name: UILabel!
    @IBOutlet weak var song_artist: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
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
