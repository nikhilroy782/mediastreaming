//
//  menuCell.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class menuCell: UITableViewCell {
    
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var img_menu: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
