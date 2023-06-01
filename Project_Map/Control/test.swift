//
// test.swift
//  Project_Map
//
//  Created by CNTT on 5/31/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import UIKit

class LinkControl: UITableViewCell {
    // Mark: Propertype
    private var button = UIButton()
    
    var linkValue:String = ""
    
//    @IBInspectable private var buttonCount:Int = 5 {
//        didSet {
//            setupRatingControl()
//        }
//    }
//    @IBInspectable private var buttonSize:CGSize = CGSize(width: 44.0, height: 44.0) {
//        didSet {
//            setupRatingControl()
//        }
//    }
    
    // Mark: Contructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupRatingControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRatingControl()
    }
    
    // Dinh nghia ham xay dung doi tuong RatingControl
    private func setupRatingControl() {
        button.setTitle("link", for: .normal)
        button.addTarget(self, action: #selector(btnRatingEventProcessing(button:)), for: .touchUpInside)
    }
    
    // ham bat su kien cho doi tuong btnRating
    @objc private func btnRatingEventProcessing(button: UIButton) {
        print("btn tap");
    }
}
