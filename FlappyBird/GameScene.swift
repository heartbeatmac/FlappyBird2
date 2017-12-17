//
//  GameScene.swift
//  FlappyBird
//
//  Created by 永島利章 on 2017/12/12.
//  Copyright © 2017年 toshiaki.nagashima2. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate /* 追加 */ {
    
    
    
    var scrollNode:SKNode!
    var wallNode:SKNode!    // 追加
    var bird:SKSpriteNode!    // 追加
    var starNode:SKNode!    // 追加（課題：星）
    
    
    // スコア用
    var score = 0
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    let userDefaults:UserDefaults = UserDefaults.standard    // 追加
    
    
    // スコア用　←追加（課題：星）
    var score2 = 0
    var scoreLabel2Node:SKLabelNode!    // ←追加
    var bestScoreLabel2Node:SKLabelNode!    // ←追加
    //   let userDefaults:UserDefaults = UserDefaults.standard    // 不要
    
    
    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let starCategory: UInt32 = 1 << 4      // 0...1000 追加（課題：星）
    
    
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)    // ←追加
        physicsWorld.contactDelegate = self // ←追加
        
        // 背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加
        
        // 星用のノード //　追加
        starNode = SKNode()   // 追加
        scrollNode.addChild(starNode)   // 追加
        
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()   // 追加
        setupStar()   // 追加（課題）
        
        setupScoreLabel()   // 追加
        setupScoreLabel2()  // 追加：星
    }
    
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.nearest
        
        // 必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // スプライトを配置する
        stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加
            
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加
            
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.nearest
        
        // 必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach { i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    // 以下追加
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory // 追加
            
            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false    // ←追加
            
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            upper.physicsBody?.categoryBitMask = self.wallCategory // 追加
            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false    // ←追加
            
            
            wall.addChild(upper)
            
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            // --- ここまで追加 ---
            
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    
    
    
    // 以下追加
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)    // ←追加
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory  // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory //| starCategory   // ←追加
        
        // アニメーションを設定
        bird.run(flap)
        
        
        // スプライトを追加する
        addChild(bird)
    }
    
    
    // 以下追加（課題：星）wall参考
    func setupStar() {
        // 星の画像を読み込む
        let starTexture = SKTexture(imageNamed: "star_a")
        starTexture.filteringMode = SKTextureFilteringMode.linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width*1.25 + starTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveStar = SKAction.moveBy(x: -movingDistance, y: 0, duration:5.0)
        
        // 自身を取り除くアクションを作成
        let removeStar = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let starAnimation = SKAction.sequence([moveStar, removeStar])
        
        // 星を生成するアクションを作成
        let createStarAnimation = SKAction.run({
            // 星関連のノードを乗せるノードを作成
            let star = SKNode()
            
            star.position = CGPoint(x: self.frame.size.width + starTexture.size().width / 2, y: 0.0)
            star.zPosition = -50.0 // 雲より手前、地面より奥、壁と同じ
            
            // 星を作成
            let item = SKSpriteNode(texture: starTexture)
            
            item.position = CGPoint(x: self.frame.size.width * 0.25, y:self.frame.size.height * 0.6)
            
            
            //  item.position = CGPoint(x: 0.0, y: item_star_y)
            star.addChild(item)
            
            // スプライトに物理演算を設定する
            item.physicsBody = SKPhysicsBody(rectangleOf: starTexture.size())    // ←追加
            
            // 衝突しても動かないように設定する
            item.physicsBody?.isDynamic = false    // ←追加
            
            
            // 衝突のカテゴリー設定
            item.physicsBody?.categoryBitMask = self.starCategory //　自分がどのカテゴリに属するのかを設定 → 自分のカテゴリ「starCategory」を指定
            item.physicsBody?.contactTestBitMask = self.birdCategory // 誰と衝突判定するかを設定 → 鳥のカテゴリ「birdCategory」を指定
            
            
            
            // 星スコア用のノード --- ここから ---
            let scoreNode2 = SKNode()
            scoreNode2.position = CGPoint(x: item.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: item.size.width, height: self.frame.size.height))
            scoreNode2.physicsBody?.isDynamic = false
            scoreNode2.physicsBody?.categoryBitMask = self.starCategory
            scoreNode2.physicsBody?.contactTestBitMask = self.starCategory
            
            star.addChild(scoreNode2)
            // --- ここまで追加 ---
            
            star.run(starAnimation)
            
            self.starNode.addChild(star)
        })
        
        
        // 次の星作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 星を作成->待ち時間->星を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createStarAnimation, waitAnimation]))
        
        
        starNode.run(repeatForeverAnimation)
    }
    
    
    
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 鳥の速度をゼロにする
        if scrollNode.speed > 0 {
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 { // --- ここから ---
            restart()
        } // --- ここまで追加 ---
    }
    
    
    
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"    // ←追加
            
            // ベストスコア更新か確認する --- ここから ---
            var bestScore = userDefaults.integer(forKey: "BEST1")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                userDefaults.set(bestScore, forKey: "BEST1")
                userDefaults.synchronize()
            } // --- ここまで追加---
            
            
            // 追加←星
        } else if  (contact.bodyA.categoryBitMask & starCategory) == starCategory || (contact.bodyB.categoryBitMask & starCategory) == starCategory{
            
            // スコア用の物体と衝突した
            print("ScoreUp2")
            score2 += 1
            scoreLabel2Node.text = "Score2:\(score2)"    // ←追加
            //  ベストスコア更新か確認する --- ここから ---
            var bestScore2 = userDefaults.integer(forKey: "BEST2")
            if score2 > bestScore2 {
                bestScore2 = score2
                bestScoreLabel2Node.text = "Best Score2:\(bestScore2)"    // ←追加
                userDefaults.set(bestScore2, forKey: "BEST2")
                userDefaults.synchronize()
            } // --- ここまで追加---
            
            
            // サウンド再生アクション
            
            let sound = SKAction.playSoundFileNamed("sound.mp3", waitForCompletion: false)
            self.run(sound, completion: ({
                print("Good!")
            })
            )
            
            // 鳥か星と衝突したら星を消す
            contact.bodyA.node?.removeFromParent()
            
            
        } else {
            // 鳥か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
        
    }
    
    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")    // ←追加
        
        score2 = 0
        scoreLabel2Node.text = String("Score2:\(score2)")    // ←追加
        
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory  // ←追加：星
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        starNode.removeAllChildren()  // ←追加：星
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    // 追加←星
    func setupScoreLabel2() {
        score2 = 0
        scoreLabel2Node = SKLabelNode()
        scoreLabel2Node.fontColor = UIColor.black
        scoreLabel2Node.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        scoreLabel2Node.zPosition = 100 // 一番手前に表示する
        scoreLabel2Node.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel2Node.text = "Score2:\(score2)"
        self.addChild(scoreLabel2Node)
        
        bestScoreLabel2Node = SKLabelNode()
        bestScoreLabel2Node.fontColor = UIColor.black
        bestScoreLabel2Node.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        bestScoreLabel2Node.zPosition = 100 // 一番手前に表示する
        bestScoreLabel2Node.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore2 = userDefaults.integer(forKey: "BEST2")
        bestScoreLabel2Node.text = "Best Score2:\(bestScore2)"
        self.addChild(bestScoreLabel2Node)
    }
    
    
    
}


//    override func viewDidLoad() {
//        super.viewDidLoad()

// Do any additional setup after loading the view.
//    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
//    }


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

//}
