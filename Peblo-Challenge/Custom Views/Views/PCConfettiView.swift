//
//  PCConfettiView.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 18/06/26.
//

import UIKit

class PCConfettiView: UIView {
    
    private let emitterLayer = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmitter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEmitter() {
        // Position the emitter at the top-center of this view container
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: bounds.size.width, height: 1)
        
        layer.addSublayer(emitterLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the emitter stretches if the view dimensions adjust
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        emitterLayer.emitterSize = CGSize(width: bounds.size.width, height: 1)
    }
    
    func birthConfetti() {
        // Kid-friendly bright, high-contrast colors
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemOrange, .systemPurple]
        
        // Generate a particle cell template for each color
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            
            // 1. Particle Speed & Gravity
            cell.birthRate = 6.0            // How many items spawn per second
            cell.lifetime = 4.0             // How long they stay on screen before fading
            cell.velocity = 150             // Initial push speed downwards
            cell.velocityRange = 50         // Random variance in speed
            cell.emissionLongitude = .pi    // Downward direction
            cell.emissionRange = .pi / 4    // Spread angle cone expansion
            
            // 2. Gravity and Physics simulation
            cell.yAcceleration = 200        // Drags the paper down like gravity
            cell.xAcceleration = 10         // Simulates a tiny cross-wind sway
            
            // 3. Playful Spinning Dynamics
            cell.spin = 3.5                 // Spin speed
            cell.spinRange = 2.0            // Variance in rotation speed
            
            // 4. Color & Shape Setup
            cell.contents = createConfettiImage()?.cgImage
            cell.color = color.cgColor
            
            return cell
        }
        
        emitterLayer.emitterCells = cells
        
        // Auto-stop spawning after 2.5 seconds so it stays a quick reward burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.emitterLayer.birthRate = 0
        }
    }
    
    // Core Graphics trick to draw a clean little square sheet of paper programmatically
    private func createConfettiImage() -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
