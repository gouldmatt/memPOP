//
//  HotspotTableViewCell.swift
//  memPOP
//
//  Created by Diego Martin on 2018-10-27.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit

class HotspotTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
