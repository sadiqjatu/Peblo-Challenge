//
//  StoryBuddyViewController.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 14/06/26.
//

import UIKit
import AVFoundation

enum NarrationState {
    case idle
    case loading
    case speaking
    case failed(String)
}

class StoryBuddyViewController: UIViewController {
    
    let characterImageView = UIImageView()
    let storyCardView      = StoryCardView(text: Misc.storyText)
    let readMeButton       = PCButton(title: "Read me a Story", backgroundColor: Colors.pebloPurple, image: Icons.speaker)
    let activityIndicator  = UIActivityIndicatorView(style: .large)

    let quizView           = QuizView()
    var targetQuizData: QuizQuestion?
    
    let confettiView       = PCConfettiView()
    
    let synthesizer        = AVSpeechSynthesizer()
    
    var currentNarrationState: NarrationState = .idle {
        didSet {
            updateUIForCurrentState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationBar()
        
        configureCharacterImageView()
        configureReadMeButton()
        configureStoryCardView()
        setupActivityIndicator()
        setupConfettiOverlay()
        
        loadMockBackendQuizJSON()
    }
    
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        synthesizer.delegate = self
        quizView.delegate    = self
    }
    
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "AI Story Buddy"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.pebloPurple,
            .font           : UIFont(name: "Poppins-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Colors.pebloPurple,
            .font:            UIFont(name: "Poppins-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.compactAppearance    = appearance
        
        
        let menuButton       = UIBarButtonItem(image: Icons.hamburger, style: .plain, target: self, action: #selector(menuTapped))
        menuButton.tintColor = Colors.pebloPurple
        navigationItem.leftBarButtonItem = menuButton
        
        let profileButton       = UIBarButtonItem(image: Icons.profile, style: .plain, target: self, action: #selector(profileTapped))
        profileButton.tintColor = Colors.pebloPurple
        navigationItem.rightBarButtonItem = profileButton
    }
    
    
    func configureCharacterImageView() {
        view.addSubview(characterImageView)
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        characterImageView.image       = Icons.robot
        characterImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            characterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterImageView.heightAnchor.constraint(equalToConstant: 150),
            characterImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    
    func configureStoryCardView() {
        view.addSubview(storyCardView)
        
        
        NSLayoutConstraint.activate([
            storyCardView.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 20),
            storyCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            storyCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            storyCardView.bottomAnchor.constraint(equalTo: readMeButton.topAnchor, constant: -20)
        ])
    }
    
    
    func configureReadMeButton() {
        view.addSubview(readMeButton)
        readMeButton.addTarget(self, action: #selector(readMeButtonPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            readMeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readMeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readMeButton.heightAnchor.constraint(equalToConstant: 70),
            readMeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor.white
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: readMeButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: readMeButton.centerXAnchor)
        ])
    }
    
    
    func updateUIForCurrentState() {
        switch currentNarrationState {
        case .idle:
            activityIndicator.stopAnimating()
            readMeButton.customTitleLabel.text  = "Read Me a Story"
            readMeButton.iconImageView.isHidden = false
            
        case .loading:
            activityIndicator.startAnimating()
            readMeButton.customTitleLabel.text  = ""
            readMeButton.iconImageView.isHidden = true
            
        case .speaking:
            activityIndicator.stopAnimating()
            readMeButton.customTitleLabel.text  = "Stop Story"
            readMeButton.iconImageView.isHidden = true
            
        case .failed(let errorMessage):
            activityIndicator.stopAnimating()
            readMeButton.customTitleLabel.text  = "Retry Reading"
            readMeButton.iconImageView.isHidden = true
            showFriendlyErrorAlert(message: errorMessage)
        }
    }
    
    
    @objc func readMeButtonPressed() {
        if case .loading = currentNarrationState { return }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            currentNarrationState = .idle
            return
        }
        
        currentNarrationState = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self  = self else { return }
            
            guard case .loading = self.currentNarrationState else { return }
            self.startTextToSpeechEngine()
        }
    }
    
    
    private func startTextToSpeechEngine() {
        guard !Misc.storyText.isEmpty else {
            currentNarrationState = .failed("Oops! Your story book seems empty right now.")
            return
        }
        
        let utterance  = AVSpeechUtterance(string: Misc.storyText)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.2
        
        guard let voice = AVSpeechSynthesisVoice(language: "en-IN") else {
            currentNarrationState = .failed("Oh no! My voice box is missing. Let's try again.")
            return
        }
        
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
    
    
    private func showFriendlyErrorAlert(message: String) {
        let alert = UIAlertController(title: "Uh Oh! 🤖", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            self?.readMeButtonPressed()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] _ in
            self?.currentNarrationState = .idle
        }))
        present(alert, animated: true)
    }
    
    
    func loadMockBackendQuizJSON() {
        let jsonString = """
        {
            "question": "What colour was Pip the Robot's lost gear?",
            "options": ["Red", "Green", "Blue", "Yellow"],
            "answer": "Blue"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        
        do {
            targetQuizData = try JSONDecoder().decode(QuizQuestion.self, from: jsonData)
        } catch {
            print("Failed to map incoming data payload: \(error)")
        }
    }
    
    
    func setupConfettiOverlay() {
        view.addSubview(confettiView)
        confettiView.translatesAutoresizingMaskIntoConstraints = false
        confettiView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
                    confettiView.topAnchor.constraint(equalTo: view.topAnchor),
                    confettiView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    confettiView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    confettiView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    @objc func menuTapped() {
        
    }
    
    
    @objc func profileTapped() {
        
    }
}


extension StoryBuddyViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        currentNarrationState = .speaking
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard case .speaking = currentNarrationState else {
            currentNarrationState = .idle
            return
        }
        
        currentNarrationState = .idle
        guard let quizData = targetQuizData else { return }
        revealQuizEngineLayout(with: quizData)
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        currentNarrationState = .idle
    }
    
    
    private func revealQuizEngineLayout(with data: QuizQuestion) {
        view.addSubview(quizView)
        quizView.alpha = 0
        quizView.render(with: data)
        
        NSLayoutConstraint.activate([
            quizView.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 20),
            quizView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quizView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            quizView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])
        
        UIView.animate(withDuration: 1.0) {
            self.storyCardView.alpha = 0
            self.readMeButton.alpha  = 0
            self.quizView.alpha      = 1
        } completion: { _ in
            self.storyCardView.removeFromSuperview()
            self.readMeButton.removeFromSuperview()
        }

    }
}


extension StoryBuddyViewController: QuizViewDelegate {
    
    func quizView(_ quizView: QuizView, didSelectOption option: String, isCorrect: Bool) {
        if isCorrect {
            characterImageView.image = Icons.robotSmiling
            confettiView.birthConfetti()
            
            UIView.animate(withDuration: 0.2) {
                self.characterImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.characterImageView.transform = .identity
                }
            }
            print("Successfully answered quiz! State: Celebration completed.")
        } else {
            quizView.shakeCard()
        }
    }
}
