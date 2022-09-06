//
//  Lft.swift
//  aurora
//
//  Created by justin on 2/22/21.
//

import UIKit

class Lft: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override var isHighlighted: Bool {
            didSet {
                print("in Lft isHighlighted")
                DispatchQueue.main.async{
                    self.backgroundColor = .blue
                }
            }
        }


}
