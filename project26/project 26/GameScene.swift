//
//  GameScene.swift
//  project 26
//
//  Created by Anisha Lamichhane on 12/1/20.
//

import SpriteKit
//we're going to use enums with a raw value. This means we can refer to the various options using names.
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        loadLevel()
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else{
                fatalError("Could not find level1.txt in the app bundle.")
            }
            guard let levelString = try? String(contentsOf: levelURL) else {
                fatalError("Could not load level1.txt from the app bundle.")
            }

            let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated(){
            for(column, letter) in line.enumerated(){
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                if letter == "x" {
//                    load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                    
                } else if letter == "v" {
//                    load a vertex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue // when it touches the player we want to be notified .
                    node.physicsBody?.collisionBitMask = 0 // it bounces off nothing
                    addChild(node)
                    
                }else if letter == "s" {
//                    load a star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                }else if letter == "f"{
//                    load finishing point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                    
                }else if letter == " " {
//                    this is an empty space -- do nothing.
                }else {
                    fatalError("Unknown letter \(letter)")
                }
            }
        }
    }
   
}
