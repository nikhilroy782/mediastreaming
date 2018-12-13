//
//  RadioTableCell.swift
//  My Music
//
//  Created by WOS Mac 1 on 13/12/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class RadioTableCell: UITableViewCell {

    @IBOutlet weak var img_radio: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
