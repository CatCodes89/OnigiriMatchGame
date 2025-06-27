//
//  GameViewController.swift
//  OnigiriMatchGame
//
//  Created by Cathy on 2025-06-18.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ viewDidLoad called")

        if let skView = self.view as? SKView {
            print("✅ SKView confirmed")

            let scene = StartScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        } else {
            print("🚨 view is not SKView")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
