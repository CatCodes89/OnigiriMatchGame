//
//  StartScene.swift
//  OnigiriMatchGame
//
//  Created by Cathy on 2025-06-18.
//

import SpriteKit

final class StartScene: SKScene {
    
    // MARK: - UI Nodes
    
    private var startButton: SKSpriteNode!
    private var helpButton: SKSpriteNode!
    
    // MARK: - Scene Life Cycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupBackground()
        setupUI()
        
        AudioManager.shared.playBackgroundMusic(named: "Silly-Fun")
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "OnigiriMatchMenu")
        background.position = .zero
        background.size = size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupUI() {
        let buttonScale: CGFloat = 0.20
        
        startButton = SKSpriteNode(imageNamed: "StartBtn")
        startButton.name = "startButton"
        startButton.setScale(buttonScale)
        startButton.zPosition = 10
        startButton.position = CGPoint(x: 0, y: -85)
        addChild(startButton)
        
        helpButton = SKSpriteNode(imageNamed: "HelpBtn")
        helpButton.name = "helpButton"
        helpButton.setScale(buttonScale)
        helpButton.zPosition = 10
        helpButton.position = CGPoint(x: 0, y: -95)
        addChild(helpButton)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if isTouch(touch, inside: startButton) {
            animateBounce(on: startButton)
        } else if isTouch(touch, inside: helpButton) {
            animateBounce(on: helpButton)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if isTouch(touch, inside: startButton) {
            playButtonSound()
            startGame()
        } else if isTouch(touch, inside: helpButton) {
            playButtonSound()
            showHelp()
        }
    }
    
    // MARK: - Helpers
    
    private func isTouch(_ touch: UITouch, inside node: SKSpriteNode) -> Bool {
        let location = touch.location(in: self)
        let inset: CGFloat = node.name == "helpButton" ? 0.05 : 0.2
        let reducedFrame = node.frame.insetBy(dx: node.size.width * inset, dy: node.size.height * inset)
        return reducedFrame.contains(location)
    }
    
    private func animateBounce(on button: SKSpriteNode) {
        let originalScale = button.xScale
        let bounce = SKAction.sequence([
            .scale(to: originalScale * 0.92, duration: 0.07),
            .scale(to: originalScale, duration: 0.07)
        ])
        button.run(bounce)
    }
    
    // MARK: - Actions
    
    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
    }
    
    private func showHelp() {
        let helpScene = HelpScene(size: size)
        helpScene.scaleMode = .aspectFill
        helpScene.userData = ["origin": "StartScene"]
        view?.presentScene(helpScene, transition: .fade(withDuration: 0.5))
    }
    
    // MARK: - Audio
    
    private func playButtonSound() {
        run(SKAction.playSoundFileNamed("Button.wav", waitForCompletion: false))
    }
}
