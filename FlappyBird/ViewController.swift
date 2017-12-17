//
//  ViewController.swift
//  FlappyBird
//
//  Created by 永島利章 on 2017/12/09.
//  Copyright © 2017年 toshiaki.nagashima2. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // SKViewに型を変換する
        let skView = self.view as! SKView
        
        // FPSを表示する
        skView.showsFPS = true
        
        // ノードの数を表示する
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size)  // ←GameSceneクラスに変更する        
        // ビューにシーンを表示する
        skView.presentScene(scene)
        
        // ノードの大きさを表示する
  //      skView.showsPhysics = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // ステータスバーを消す --- ここから ---
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    } // --- ここまで追加 ---
    
    
}

