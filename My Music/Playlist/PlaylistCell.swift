//
//  PlaylistCell.swift
//  My Music
//
//  Created by WOS on 14/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlist_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
