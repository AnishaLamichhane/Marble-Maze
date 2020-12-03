//
//  GameScene.swift
//  project 26
//
//  Created by Anisha Lamichhane on 12/1/20.
//
//

import CoreMotion
import SpriteKit
//we're going to use enums with a raw value. This means we can refer to the various options using names.
enum CollisionTypes: UInt32 {
	case player = 1
	case wall = 2
	case star = 4
	case vortex = 8
	case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
	var lastTouchPosition: CGPoint?
    var wall: SKSpriteNode!
    var star : SKSpriteNode!
    var finish : SKSpriteNode!
    var vortex : SKSpriteNode!
    var teleport1 : SKSpriteNode!
    var teleport2 : SKSpriteNode!

    var motionManager: CMMotionManager!  // property to handle the coremotion

    var isGameOver = false
	var scoreLabel: SKLabelNode!

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

    override func didMove(to view: SKView) {
		createBackground(background: "background.png")
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.position = CGPoint(x: 16, y: 36)
        scoreLabel.zPosition = 2
		addChild(scoreLabel)

		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		physicsWorld.contactDelegate = self

		loadLevel(level: "level1")
		createPlayer()

		motionManager = CMMotionManager()
		motionManager.startAccelerometerUpdates()
    }
    
    func createBackground(background: String){
        let background = SKSpriteNode(imageNamed: background)
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

    }

    func loadLevel(level: String) {
        guard let levelPath = Bundle.main.path(forResource: level, ofType: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")}
        guard  let levelString = try? String(contentsOfFile: levelPath)  else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        let lines = levelString.components(separatedBy: "\n")

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) - 30)

                if letter == "x" {
                    // load wall
                    createWall(position: position)
                    
                } else if letter == "v"  {
                    // load vortex
                    createVortex(position: position)
                    
                } else if letter == "s"  {
                    // load star
                    createStar(position: position)
                    
                }else if letter == "t" {
//                            load teleport 1
                    creaTeteleport1(position: position)
                } else if letter == "q"{
//                            load teleport 2
                    createTeleport2(position: position)
                    
                }else if letter == "f"  {
                    // load finish
                    createFinish(position: position)
                    
               }//else {
//                    fatalError("Unknown letter found")
//                }
            }
        }
    }
    
	

	func createPlayer() {
		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x: 96, y: 672)
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.linearDamping = 0.5

		player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
		player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
		addChild(player)
	}
    //    these three code is just for touch in the mac but if you want to test the device only on the ipad you donot need these three methods touches began, touches moved and touches ended and update method.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			lastTouchPosition = location
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			lastTouchPosition = location
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}

	override func update(_ currentTime: TimeInterval) {
		guard isGameOver == false else { return }
		#if targetEnvironment(simulator)
			if let currentTouch = lastTouchPosition {
				let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
				physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
//                this is not a mistake! as you rotate the devive by landscape right the coordinates also changes
			}
		#else
			if let accelerometerData = motionManager.accelerometerData {
				physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
			}
		#endif
	}
    //it is called whenever two bodies is contacted with each other.
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.node == player {
			playerCollided(with: contact.bodyB.node!)
		} else if contact.bodyB.node == player {
			playerCollided(with: contact.bodyA.node!)
		}
	}

	func playerCollided(with node: SKNode) {
		if node.name == "vortex" {
			player.physicsBody?.isDynamic = false
			isGameOver = true
			score -= 1

			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(to: 0.0001, duration: 0.25)
			let remove = SKAction.removeFromParent()
			let sequence = SKAction.sequence([move, scale, remove])

			player.run(sequence) { [unowned self] in
				self.createPlayer()
				self.isGameOver = false
			}
		} else if node.name == "star" {
			node.removeFromParent()
			score += 1
        } else if node.name == "teleport1" {
            print("teleport1")
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            
            let sequence = SKAction.sequence([move, scale])
            let newPosition = CGPoint(x: teleport2.position.x + 30, y: teleport2.position.y)
            
            player.run(sequence) { [weak self] in
                self?.player.position = newPosition
                let scaleBack = SKAction.scale(to: 1, duration: 0.25)
                self?.player.run(scaleBack)
            }
            
        }else if node.name == "finish" {
			// next level?
           player.removeFromParent()
           removeNode(name: "star")
           removeNode(name: "finish")
           removeNode(name: "wall")
           removeNode(name: "vortex")
           removeNode(name: "background")
           removeNode(name: "teleport1")
           removeNode(name: "teleport2")
          
          
           loadLevel(level: "level2")
            createBackground(background: "back3.png")
           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               self.createPlayer()
           }
        }
    }
    func removeNode(name: String) {
        self.enumerateChildNodes(withName: name) { (node, _) in
            node.removeFromParent()
        }
    }
    
    func createWall(position: CGPoint){
        wall = SKSpriteNode(imageNamed: "block")
        wall.position = position
        wall.zPosition = 1
        
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        wall.physicsBody?.isDynamic = false
        addChild(wall)
    }
    func createStar(position: CGPoint){
        star = SKSpriteNode(imageNamed: "star")
        star.name = "star"
        star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.width / 2)
        star.physicsBody?.isDynamic = false

        star.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        star.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        star.physicsBody?.collisionBitMask = 0
        star.position = position
        addChild(star)
    }
    func createVortex(position: CGPoint){
        vortex = SKSpriteNode(imageNamed: "vortex")
        vortex.name = "vortex"
        vortex.position = position
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
        vortex.physicsBody = SKPhysicsBody(circleOfRadius: vortex.size.width / 2)
        vortex.physicsBody?.isDynamic = false

        vortex.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        vortex.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue // when it touches the player we want to be notified .
        vortex.physicsBody?.collisionBitMask = 0 // it bounces off nothing
        addChild(vortex)
        
    }
    func createFinish(position: CGPoint){
        let finish = SKSpriteNode(imageNamed: "finish")
        finish.name = "finish"
        finish.physicsBody = SKPhysicsBody(circleOfRadius: finish.size.width / 2)
        finish.physicsBody?.isDynamic = false

        finish.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        finish.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        finish.physicsBody?.collisionBitMask = 0
        finish.position = position
        addChild(finish)
        
    }
    func creaTeteleport1(position: CGPoint){
        teleport1 = SKSpriteNode(imageNamed: "Teleport")
        teleport1.name = "teleport1"
        teleport1.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        teleport1.physicsBody?.isDynamic = false
        teleport1.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        teleport1.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        teleport1.position = position
        addChild(teleport1)
    
    }
    func createTeleport2(position: CGPoint){
        teleport2 = SKSpriteNode(imageNamed: "Teleport")
        teleport2.name = "teleport2"
        teleport2.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        teleport2.physicsBody?.isDynamic = false
        teleport2.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        teleport2.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        teleport2.position = position
        addChild(teleport2)
    }
}
