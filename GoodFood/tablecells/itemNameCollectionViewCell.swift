//
//  itemNameCollectionViewCell.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-06.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import Foundation
import UIKit

class itemNameCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet weak var label: UILabel!
    
    
    @IBOutlet weak var imgitem: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgitem.frame = CGRect(x: 0, y: 0, width: 50, height:50)
    }
    
    
}
