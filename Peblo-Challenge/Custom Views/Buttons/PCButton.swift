//
//  PCButton.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 18/06/26.
//

import UIKit

class PCButton: UIButton {
    
    let iconImageView    = UIImageView()
    let customTitleLabel = PCTitleLabel(textAlignment: .center, fontSize: 22)
    let contentStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupLayout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(title: String, backgroundColor: UIColor, image: UIImage? = nil) {
        super.init(frame: .zero)
        self.customTitleLabel.text = title
        self.backgroundColor       = backgroundColor
        
        let boldConfig             = UIImage.SymbolConfiguration(weight: .bold)
        let thickendImage          = image?.withConfiguration(boldConfig)
        self.iconImageView.image   = thickendImage
        
        configure()
        setupLayout()
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius            = 32
        clipsToBounds                 = false
        
        customTitleLabel.textColor    = .white
        
        iconImageView.contentMode     = .scaleAspectFit
        iconImageView.tintColor       = .white
        
        contentStackView.axis         = .horizontal
        contentStackView.alignment    = .center
        contentStackView.distribution = .fill
        contentStackView.spacing      = 12
        
        contentStackView.isUserInteractionEnabled = false
        
        //3d effect
        layer.shadowColor             = UIColor.black.cgColor
        layer.shadowOpacity           = 0.25
        layer.shadowOffset            = CGSize(width: 0, height: 6)
        layer.shadowRadius            = 0
    }
    
    
    private func setupLayout() {
        addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(customTitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.05) {
                if self.isHighlighted {
                    // Slide down 4 points
                    self.transform = CGAffineTransform(translationX: 0, y: 4)
                    // Flatten shadow to match compression
                    self.layer.shadowOffset = CGSize(width: 0, height: 2)
                } else {
                    // Bounce back up instantly
                    self.transform = .identity
                    self.layer.shadowOffset = CGSize(width: 0, height: 6)
                }
            }
        }
    }
}
