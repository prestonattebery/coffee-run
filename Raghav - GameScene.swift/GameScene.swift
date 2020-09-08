//
//  GameScene.swift
//  RPG Study
//
//  Created by Preston Attebery on 9/2/20.
//  Copyright © 2020 Preston Attebery. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {

    case player = 1
    case building = 2
    case somethingElse = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Nodes
    var cameraNode : SKNode?

    var thePlayer:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 0.15
    let panGesture = UIPanGestureRecognizer()
    var panBeginLocation = CGPoint.zero

    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == UIGestureRecognizer.State.began {
            self.touchDown(atPoint: panGesture.location(in: panGesture.view))
        }
        else if panGesture.state == UIGestureRecognizer.State.changed {
            self.touchMoved(toPoint: panGesture.location(in: panGesture.view))
        }
        else if panGesture.state == UIGestureRecognizer.State.ended {
            self.touchUp(atPoint: panGesture.location(in: panGesture.view))
        }
        else {
            self.touchCancelled(atPoint: panGesture.location(in: panGesture.view))
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("began")
        print(pos)
        panBeginLocation = pos

    }

    func touchMoved(toPoint pos : CGPoint) {
        print("moved")
        print(pos)
    }

    func touchUp(atPoint pos : CGPoint) {
        print("ended")
        print(pos)
        
        let difference = CGPoint(x: pos.x - self.panBeginLocation.x, y: pos.y - self.panBeginLocation.y)
        print(difference)
            
        if abs(difference.x) > abs(difference.y) {
            if difference.x > 0 {
                print("right")
            } else {
                print("left")
            }
        } else  {
            if difference.y > 0 {
                print("down")
            } else {
                print("up")
            }
        }
    }
    func touchCancelled(atPoint pos : CGPoint) {
        print("cancelled")
        print(pos)
    }


    override func didMove(to view: SKView) {
        
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode

        self.physicsWorld.contactDelegate = self

        self.physicsWorld.gravity = CGVector(dx: 1, dy: 0)
        
        panGesture.addTarget(self, action:#selector(GameScene.handlePanGesture(panGesture:)))
        self.view!.addGestureRecognizer(panGesture)

//        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
//        tapRec.numberOfTouchesRequired = 1
//        tapRec.numberOfTapsRequired = 1
//        self.view!.addGestureRecognizer(tapRec)


        if let somePlayer:SKSpriteNode = self.childNode(withName: "Player") as? SKSpriteNode {

            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.building.rawValue

        }

        for node in self.children {

            if (node.name == "Building") {

                if (node is SKSpriteNode) {

                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue

                    print ("found a building")
                }
            }
        }

    }

    //MARK: Gesture Recognizers

//    @objc func tappedView() {
//
//    print("tapped")
//
//    }

   
    func cleanUP(){

        //only need to call when different scene class

        for gesture in (self.view?.gestureRecognizers)! {

            self.view?.removeGestureRecognizer(gesture)

        }
    }





    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String) {

        thePlayer.physicsBody?.isDynamic = true
        thePlayer.physicsBody?.affectedByGravity = true

        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed )!

        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed )

        let group:SKAction = SKAction.group( [ walkAnimation, moveAction ] )

        let finish:SKAction = SKAction.run {

            self.thePlayer.physicsBody?.isDynamic = false
            self.thePlayer.physicsBody?.affectedByGravity = false
        }

        let seq:SKAction = SKAction.sequence( [group, finish] )

        thePlayer.run(seq)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Camera
        cameraNode?.position.x = thePlayer.position.x
        cameraNode?.position.y = thePlayer.position.y

    }

    //MARK: Physics Contacts

    func didBegin(_ contact: SKPhysicsContact) {

        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue) {

            print("touched a building")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue) {

            print("touched a building")
        }
    }
}

