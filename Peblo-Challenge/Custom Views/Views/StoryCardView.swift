//
//  StoryCardView.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 18/06/26.
//

import UIKit

class StoryCardView: UIView {

    let storyText = PCSecondaryTitleLabel(textAlignment: .left, fontSize: 20)
    let padding: CGFloat = 24
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(text: String) {
        super.init(frame: .zero)
        self.storyText.text = text
        configure()
    }
    
    
    private func configure() {
        addSubview(storyText)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 24
        backgroundColor    = .secondarySystemBackground
        
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 10
        layer.shadowOpacity = 0.05
        layer.masksToBounds = false
        
        layer.borderColor   = UIColor.systemGray3.cgColor
        layer.borderWidth   = 1
        
        storyText.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            storyText.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            storyText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            storyText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            storyText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
}
