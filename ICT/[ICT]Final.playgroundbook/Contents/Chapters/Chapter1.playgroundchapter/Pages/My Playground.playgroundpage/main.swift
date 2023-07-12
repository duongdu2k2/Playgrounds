//#-hidden-code

import SpriteKit
import PlaygroundSupport
import UIKit
import GameScene
import Foundation
import Dispatch


let skView = SKView(frame: .zero)
let gameScene = GameScene(size: UIScreen.main.bounds.size)

func sizePlayer(_ indext : Double){
    gameScene.overrideSizePlayer(indext)
}
func sizeBullet(_ indext : Double){
    gameScene.sizeBullet = indext
}
func sizeAlien(_ indext : Double){
    gameScene.sizeAlien = indext
}

func createBulletsClone(){
    gameScene.createBulletsClone()
}
func bulletGoToPlayer(){
    gameScene.bulletGoToPlayer()
}
func bulletGlideToEdgeTop(){
    gameScene.bulletGlideToEdgeTop()
}
func addBulletClone(){
    gameScene.addBulletClone()
}

func createAliensClone(){
    gameScene.createAliensClone()
}
func alienGoToRandom(){
    gameScene.alienGoToRandom()
}
func alienGlideToEdgeBottom(){
    gameScene.alienGlideToEdgeBottom()
}
func addAlienClone(){
    gameScene.addAlienClone()
}

func foreverCreateBulletClone(){
    gameScene.bulletClone.run(SKAction.repeatForever(SKAction.sequence([bulletWait, bulletSpawn])))
}

func foreverCreateAlienClone(){
    gameScene.alienClone.run(SKAction.repeatForever(SKAction.sequence([redAlienWait, redAlienSpawn])))
}

func removeAlien(){
    gameScene._removeAlien = true
}

func removeBullet(){
    gameScene._removeBullet = true
}

func stopAll(){
    PlaygroundPage.current.finishExecution()
}

func addPlayer(_ name: String){
    gameScene.overridePlayer(name)
    gameScene.addChild(gameScene.player)
    sizePlayer(100)
}

func addBullet(_ name: String){
    gameScene.addChild(gameScene.bulletClone)
}

func addAlien(_ name: String){
    gameScene.addChild(gameScene.alienClone)
}

func gameOver(){
    gameScene.overrideBackground()
}

// Di chuyển theo vị trí chạm trên màn hình
func handleTouchesMoved(){
    gameScene.checkHandleTouchesMoved()
}

// Tạo luồng chương trình chạy song song
let queue = DispatchQueue(label: "com.example.myqueue")
let queue2 = DispatchQueue(label: "com.example.myqueue")

var touchAlien = false
queue.async {
    while true {
        if gameScene.touchAlien{
            touchAlien = true
            break
        }
    }
}
var touchBullet = false
queue2.async {
    while true {
        if gameScene.touchBullet{
            touchBullet = true
            break
        }
    }
}
gameScene.newBg.removeFromParent()
//#-end-hidden-code
//:# main:
// Thêm các nhân vật vào trò chơi
//#-editable-code
addPlayer("Player4.png")
addBullet("Bullet.png")
addAlien("Alien.png")
//#-end-editable-code


//:# Phần code nhân vật Player:
// Nhân vật Player di chuyển theo vị trí chạm vào màn hình
//#-editable-code
handleTouchesMoved()
sizeAlien(100)
sizePlayer(100)
sizeBullet(100)
//#-end-editable-code

//#-hidden-code
queue.async {
//#-end-hidden-code
// Xử lý điều kiện chạm Alien
//#-editable-code
while true {
    if touchAlien{
        gameOver()
        stopAll()
    }
}
//#-end-editable-code
//#-hidden-code
}
//#-end-hidden-code


//:# Phần code nhân vật Bullet:
// Liên tục tạo bản sao
//#-hidden-code
let bulletWait = SKAction.wait(forDuration: gameScene.bulletFrequency)
let bulletSpawn = SKAction.run(whenStartBulletClone)
//#-end-hidden-code
//#-editable-code
foreverCreateBulletClone()
//#-end-editable-code

// Khi một bản sao của Bullet được tạo
//#-editable-code
func whenStartBulletClone() {
    createBulletsClone()
    bulletGoToPlayer()
    bulletGlideToEdgeTop()
    addBulletClone()
}
//#-end-editable-code


//:# Phần code nhân vật Alien:
// Liên tục tạo bản sao
//#-hidden-code
let redAlienWait = SKAction.wait(forDuration: gameScene.redAlienfrequency)
let redAlienSpawn = SKAction.run(whenStartAlienClone)
//#-end-hidden-code
//#-editable-code
foreverCreateAlienClone()
//#-end-editable-code

// Khi một bản sao của Alien được tạo
//#-editable-code
func whenStartAlienClone() {
    createAliensClone()
    alienGoToRandom()
    alienGlideToEdgeBottom()
    addAlienClone()
}
//#-end-editable-code

//#-hidden-code
queue2.async {
//#-end-hidden-code
// Xử lý điều kiện chạm Bullet
//#-editable-code
while true {
    if touchBullet{
        removeAlien()
        removeBullet()
    }
}
//#-end-editable-code
//#-hidden-code
}
//#-end-hidden-code

//#-hidden-code
gameScene.scaleMode = .aspectFill
skView.presentScene(gameScene)
skView.preferredFramesPerSecond = 60

PlaygroundPage.current.liveView = skView
PlaygroundPage.current.wantsFullScreenLiveView = true
//#-end-hidden-code

