//
//  AlbumTableCell.swift
//  My Music
//
//  Created by WOS on 07/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class AlbumTableCell: UITableViewCell {
    
    @IBOutlet weak var album_image: UIImageView!
    @IBOutlet weak var album_name: UILabel!
    @IBOutlet weak var album_artist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
