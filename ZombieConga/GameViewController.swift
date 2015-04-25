//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Gelei Chen on 15/3/17.
//  Copyright (c) 2015年 Purdue Bang. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scence = GameScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scence.scaleMode = .AspectFill
        skView.presentScene(scence)
        
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
