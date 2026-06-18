//
//  UIView+Ext.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 14/06/26.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView... ) {
        for view in views {
            addSubview(view)
        }
    }
}
