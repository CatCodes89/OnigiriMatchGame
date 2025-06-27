//
//  HelpScene.swift
//  OnigiriMatchGame
//
//  Created by Cathy on 2025-06-22.
//

import SpriteKit
import UIKit

final class HelpScene: SKScene {

    // MARK: - Nodes

    private var backButton: SKLabelNode!
    private var scrollView: UIScrollView?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .black
        alpha = 0

        run(.fadeIn(withDuration: 1.0))

        setupUI(in: view)
    }

    override func willMove(from view: SKView) {
        scrollView?.removeFromSuperview()
    }

    // MARK: - Setup

    private func setupUI(in view: SKView) {
        setupBackButton()
        setupScrollableText(in: view)
        setupCloseButton(in: view)
    }

    private func setupBackButton() {
        backButton = SKLabelNode(text: "Back")
        backButton.fontName = "AvenirNext-Bold"
        backButton.fontSize = 24
        backButton.fontColor = .white
        backButton.position = CGPoint(x: -size.width / 2 + 60, y: size.height / 2 - 60)
        backButton.name = "backButton"
        addChild(backButton)
    }

    private func setupScrollableText(in view: SKView) {
        let scrollViewWidth = size.width * 0.8
        let scrollViewHeight = size.height * 0.7

        let scrollView = UIScrollView(frame: CGRect(
            x: (view.bounds.width - scrollViewWidth) / 2,
            y: (view.bounds.height - scrollViewHeight) / 2,
            width: scrollViewWidth,
            height: scrollViewHeight
        ))
        scrollView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scrollView.layer.cornerRadius = 12
        scrollView.alpha = 0

        let tutorialLabel = UILabel()
        tutorialLabel.numberOfLines = 0
        tutorialLabel.textColor = .white
        tutorialLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        tutorialLabel.textAlignment = .center
        tutorialLabel.text = """
        How to Play:

        1. Tap tiles to select them.
        
        2. Swap two adjacent tiles to create matches of 3 or more.
        
        3. Matches will clear tiles and earn you points.
        
        4. Use hints to highlight possible moves (3 hints per level).
        
        5. Use the special power-up tile to clear a cross shape on the board.
        
        6. Reach the goal score to progress to the next level.

        Good luck and have fun!
        """

        let maxLabelWidth = scrollViewWidth - 20
        let labelSize = tutorialLabel.sizeThatFits(
            CGSize(width: maxLabelWidth, height: .greatestFiniteMagnitude)
        )
        tutorialLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: maxLabelWidth,
            height: labelSize.height
        )

        scrollView.addSubview(tutorialLabel)
        scrollView.contentSize = CGSize(
            width: scrollViewWidth,
            height: labelSize.height + 20
        )

        view.addSubview(scrollView)
        self.scrollView = scrollView

        UIView.animate(withDuration: 1.0) {
            scrollView.alpha = 1.0
        }
    }

    private func setupCloseButton(in view: SKView) {
        let buttonSize: CGFloat = 40
        let padding: CGFloat = 20

        let closeButton = SKShapeNode(
            rectOf: CGSize(width: buttonSize, height: buttonSize),
            cornerRadius: 8
        )
        closeButton.name = "closeButton"
        closeButton.fillColor = .black.withAlphaComponent(0.5)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.zPosition = 1000

        let topRight = CGPoint(
            x: view.bounds.width - padding - buttonSize / 2,
            y: padding + buttonSize / 2
        )
        closeButton.position = convertPoint(fromView: topRight)

        let xLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        xLabel.text = "X"
        xLabel.fontSize = 24
        xLabel.fontColor = .white
        xLabel.verticalAlignmentMode = .center
        xLabel.horizontalAlignmentMode = .center
        xLabel.zPosition = 1001
        closeButton.addChild(xLabel)

        addChild(closeButton)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let touchedNodes = nodes(at: location)

        if touchedNodes.contains(where: { $0.name == "backButton" }) {
            goBack()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let touchedNodes = nodes(at: location)

        if touchedNodes.contains(where: { $0.name == "closeButton" }) {
            goBack()
        }
    }

    // MARK: - Navigation

    private func goBack() {
        run(.fadeOut(withDuration: 1.0))

        UIView.animate(withDuration: 1.0, animations: {
            self.scrollView?.alpha = 0
        }) { _ in
            self.scrollView?.removeFromSuperview()

            let origin = self.userData?["origin"] as? String ?? "StartScene"
            let nextScene: SKScene = (origin == "StartScene")
                ? StartScene(size: self.size)
                : GameScene(size: self.size)

            nextScene.scaleMode = .aspectFill
            self.view?.presentScene(nextScene)
        }
    }
}
