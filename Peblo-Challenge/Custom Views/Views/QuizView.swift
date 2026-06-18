//
//  QuizView.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 18/06/26.
//

import UIKit

protocol QuizViewDelegate: AnyObject {
    func quizView(_ quizView: QuizView, didSelectOption option: String, isCorrect: Bool)
}

class QuizView: UIView {
    
    private let questionLabel   = PCSecondaryTitleLabel(textAlignment: .center, fontSize: 24)
    private let optionsStackView = UIStackView()
    
    weak var delegate: QuizViewDelegate?
    private var questionData: QuizQuestion?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(questionLabel)
        questionLabel.numberOfLines = 0
        
        addSubview(optionsStackView)
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis         = .vertical
        optionsStackView.spacing      = 10
        optionsStackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            questionLabel.heightAnchor.constraint(equalToConstant: 52),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    //The Renderer engine: Handles 3, 4 or 5 choices perfectly without hardcoding
    func render(with quiz: QuizQuestion) {
        self.questionData  = quiz
        questionLabel.text = quiz.question
        
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for option in quiz.options {
            
            let optionView  = UIView()
            let titleLabel  = PCSecondaryTitleLabel(textAlignment: .left, fontSize: 22)
            let circleImage = UIImageView()
            
            optionView.layer.cornerRadius = 12
            optionView.layer.borderWidth  = 2
            optionView.layer.borderColor  = UIColor.separator.cgColor
            optionView.isUserInteractionEnabled = true
            optionView.translatesAutoresizingMaskIntoConstraints = false
            
            optionsStackView.addArrangedSubview(optionView)
            
            optionView.addSubviews(titleLabel, circleImage)
            circleImage.translatesAutoresizingMaskIntoConstraints = false
            
            titleLabel.text         = option
            circleImage.image       = Icons.circle
            circleImage.contentMode = .scaleAspectFit
            circleImage.tintColor   = .systemGray3
            
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: optionView.leadingAnchor, constant: 24),
                titleLabel.heightAnchor.constraint(equalToConstant: 24),
                
                circleImage.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
                circleImage.trailingAnchor.constraint(equalTo: optionView.trailingAnchor, constant: -16),
                circleImage.heightAnchor.constraint(equalToConstant: 28),
                circleImage.widthAnchor.constraint(equalToConstant: 28)
            ])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            optionView.addGestureRecognizer(tap)
            
        }
    }
    
    
    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        
        guard let tappedView = sender.view else { return }
        
        guard let titleLabel = tappedView.subviews.compactMap({ $0 as? PCSecondaryTitleLabel }).first,
              let circleImage = tappedView.subviews.compactMap({ $0 as? UIImageView }).first,
              let selectedOption = titleLabel.text,
              let correctAnswer  = questionData?.answer else { return }
        
        let isCorrect = (selectedOption == correctAnswer)
        
        UIView.animate(withDuration: 0.25) {
            if isCorrect {  //success
                tappedView.backgroundColor   = .systemGreen.withAlphaComponent(0.15)
                tappedView.layer.borderColor = UIColor.systemGreen.cgColor
                titleLabel.textColor         = .systemGreen
                
                circleImage.image            = Icons.checkmark
                circleImage.tintColor        = .systemGreen
                
                self.isUserInteractionEnabled = false
                
            } else {       //Failure
                tappedView.backgroundColor = .systemRed.withAlphaComponent(0.1)
                tappedView.layer.borderColor = UIColor.systemRed.cgColor
                titleLabel.textColor = .systemRed
                
                circleImage.image = UIImage(systemName: "xmark.circle.fill")
                circleImage.tintColor = .systemRed
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                UIView.animate(withDuration: 0.3) {
                                    tappedView.backgroundColor = .clear
                                    tappedView.layer.borderColor = UIColor.separator.cgColor
                                    titleLabel.textColor = .label
                                    circleImage.image = Icons.circle
                                    circleImage.tintColor = .systemGray3
                                }
                }
            }
        }
        
        delegate?.quizView(self, didSelectOption: selectedOption, isCorrect: isCorrect)
    }
    
    
    func shakeCard() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration       = 0.4
        animation.values         = [-12.0, 12.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        layer.add(animation, forKey: "shake")
        
        let feedbackGenerator    = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
    }
}
