//
//  SearchTableViewCell.swift
//  aurora
//
//  Created by justin on 2/2/21.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellCategory: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
