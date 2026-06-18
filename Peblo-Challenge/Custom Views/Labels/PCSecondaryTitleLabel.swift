//
//  PCSecondaryTitleLabel.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 14/06/26.
//

import UIKit

class PCSecondaryTitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font          = UIFont(name: "Poppins-Regular", size: fontSize)
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth     = true
        textColor                     = .label
        minimumScaleFactor            = 0.7
        lineBreakMode                 = .byTruncatingTail
    }
}
