import SpriteKit
import UIKit
import Foundation
import Dispatch

public class GameScene: SKScene, SKPhysicsContactDelegate {
    public var touchAlien = false
    public var touchBullet = false
    public var _removeAlien = false
    public var _removeBullet = false
    
    // Player Sprite Node
    public var player = SKSpriteNode()
    // public var player = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "PlayerShip.png")))
    public var newBg = SKSpriteNode()
    public var bulletClone = SKSpriteNode()
    public var alienClone = SKSpriteNode()

    public var sizeBullet = 100.0
    public var sizeAlien = 100.0
    
    // Spawn Time Frequencies
    public var redAlienfrequency = 0.5
    public var bulletFrequency = 0.3

    public override func didMove(to view: SKView) {
        // Background Sprite Node and Properties
        var bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Space.png")))
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bg)
        
        // Player Properties
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 6)
        player.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.player.rawValue
        player.physicsBody?.contactTestBitMask = PhysicsCategories.redAlien.rawValue | PhysicsCategories.blueAlien.rawValue
        player.physicsBody?.isDynamic = false

        /*The game has a contact delegate, so when two sprite nodes collide with each other, 
 it will perform the contact and collision. */
        physicsWorld.contactDelegate = self
    }
    

    public func didBegin(_ contact: SKPhysicsContact){
        
        let contactCategory: PhysicsCategories = [contact.bodyA.category, contact.bodyB.category]
        // Contact Categories contains these physics categories
        if contactCategory.contains([.redAlien, .bullet]) {
            touchBullet = true
            if contact.bodyA.category == .redAlien {
                self.collisionWithBulletAndRedAlien(redAlien: contact.bodyA.node as? SKSpriteNode, bullet: contact.bodyB.node as? SKSpriteNode)
                // If either contact bodies is nil. It will return it.
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithBulletAndRedAlien(redAlien: contact.bodyB.node as? SKSpriteNode, bullet: contact.bodyA.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            }
        } else if contactCategory.contains([.redAlien, .player]) {
            touchAlien = true
            if contact.bodyA.category == .redAlien {
                self.collisionWithPlayerAndRedAlien(redAlien: contact.bodyA.node as? SKSpriteNode, player: contact.bodyB.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            } else {
                self.collisionWithPlayerAndRedAlien(redAlien: contact.bodyB.node as? SKSpriteNode, player: contact.bodyA.node as? SKSpriteNode)
                if (contact.bodyA.node == nil || contact.bodyB.node == nil) {
                    return 
                }
            }
        } else {
            preconditionFailure("Unexpected collision type: \(contactCategory)")
        }
    }
    // If the bullet colldies with red aliens, perform this function.
    func collisionWithBulletAndRedAlien(redAlien: SKSpriteNode?, bullet: SKSpriteNode?) {
        // Removes bullet and red aliens from view
        if _removeBullet{
            bullet?.removeFromParent()
        } 
        if _removeAlien{
            redAlien?.removeFromParent()
        }
    }

    // If player and red aliens collide with each other, perform this function.
    func collisionWithPlayerAndRedAlien(redAlien: SKSpriteNode?, player: SKSpriteNode?) {
        redAlien?.removeFromParent()
        player?.removeFromParent()
        // Removes all children, actions, and score label from the view
        self.removeAllChildren()
        self.removeAllActions()
    }
    
    public func createBulletsClone() {
        // Bullet Sprite Node
        bulletClone = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Bullet.png")))
        bulletClone.zPosition = -5
        // Bullet Physics Body Properties
        bulletClone.size = CGSize(width: size.width * 0.015 * (sizeBullet / 100), height: size.width * 0.015 * (sizeBullet / 100))
        bulletClone.physicsBody = SKPhysicsBody(rectangleOf: bulletClone.size)
        bulletClone.physicsBody?.categoryBitMask = PhysicsCategories.bullet.rawValue
        bulletClone.physicsBody?.contactTestBitMask = PhysicsCategories.redAlien.rawValue
        bulletClone.physicsBody?.affectedByGravity = false
        bulletClone.physicsBody?.isDynamic = false
    }
    public func bulletGoToPlayer() {
        bulletClone.position = CGPoint(x: player.position.x, y: player.position.y)
    }
    public func bulletGlideToEdgeTop() {
        // Performs SKAction once the game is started
        let action = SKAction.moveTo(y: self.size.height + 30, duration: 1.5)
        let actionDone = SKAction.removeFromParent()
        bulletClone.run(SKAction.sequence([action, actionDone]))
        
    }
    public func addBulletClone() {
        // Adds bullet as a child to the view
       self.addChild(bulletClone)
    }
    

    public func createAliensClone() {
        // Alien Sprite Node
        alienClone = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Alien.png")))
        alienClone.size = CGSize(width: size.width * 0.03 * (sizeAlien / 100), height: size.width * 0.03 * (sizeAlien / 100))
        // Alien Physics Body Properties
        alienClone.physicsBody = SKPhysicsBody(rectangleOf: alienClone.size)
        alienClone.physicsBody?.categoryBitMask = PhysicsCategories.redAlien.rawValue
        alienClone.physicsBody?.contactTestBitMask = PhysicsCategories.bullet.rawValue
        alienClone.physicsBody?.affectedByGravity = false
        alienClone.physicsBody?.isDynamic = true
        alienClone.physicsBody?.collisionBitMask = 0
    }
    public func alienGoToRandom() {
        var minValue = self.size.width / 12
        var maxValue = self.size.width 
        var spawnPoint = UInt32(maxValue - minValue)
        alienClone.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
    }
    public func alienGlideToEdgeBottom() {
        let action = SKAction.moveTo(y: -50, duration: 3.0)
        alienClone.run(SKAction.repeatForever(action))
        let actionDone = SKAction.removeFromParent()
        alienClone.run(SKAction.sequence([action, actionDone]))
    }
    public func addAlienClone() {
        // Adds alien as a child to the view
        self.addChild(alienClone)
    }

    public var shouldHandleTouchesMoved = false

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard shouldHandleTouchesMoved else {
            return
        }

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
            player.position.y = location.y
        }   
    }
    
    public func overridePlayer(_ name: String) {
        player = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: name)))
    }

    public func overrideSizePlayer(_ indext: Double) {
        player.size = CGSize(width: size.width * 0.05 * (indext / 100), height: size.width * 0.05 * (indext / 100))
    }

    
    public func overrideBackground() {
        newBg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "GameOver.png")))
        newBg.zPosition = 0
        newBg.position = CGPoint(x: frame.midX, y: frame.midY)
        newBg.size = CGSize(width: size.width*0.7, height: size.height)
        self.addChild(newBg)
        sleep(1)
    }

    public func checkHandleTouchesMoved(){
        shouldHandleTouchesMoved = true
    }
}


