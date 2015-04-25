import SpriteKit

class GameScene: SKScene {
    
    
    var zombie : SKSpriteNode?
    var lastUpdateTime : NSTimeInterval = 0
    var dt : NSTimeInterval = 0
    let zombieMovePointsPerSec : CGFloat = 480.0
    var velocity = CGPointZero
    let playableRect : CGRect
    var lastTouchLocation : CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    let zombieAnimation : SKAction
    let catCollisionSound : SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound : SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var invincible = false
    let catMovePointsPerSec:CGFloat = 480.0
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeigh = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeigh)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeigh)
        var textures :[SKTexture] = []
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func debugDrawPlayableArea(){
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        self.zombie = SKSpriteNode(imageNamed: "zombie1")
        self.zombie!.position = CGPoint(x: 400, y: 400)
        self.zombie!.zPosition = 100
        addChild(zombie!)
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.zPosition = -1
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
        //self.zombie!.runAction(SKAction.repeatActionForever(zombieAnimation))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))
        
        debugDrawPlayableArea()
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - self.zombie!.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
                self.zombie!.position = lastTouchLocation!
                velocity = CGPointZero
                stopZombieAnimation()
            } else {
                moveSprite(self.zombie!, velocity: velocity)
                rotateSprite(zombie!, direction: velocity, rotateRadiansPerSec: self.zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
        //checkCollisions()
        moveTrain()
        
    }
    
    func moveSprite(sprite:SKSpriteNode,velocity:CGPoint){
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    func moveZombieToward(location:CGPoint){
        startZombieAnimation()
        let offset = location - zombie!.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    func sceneTouched(touchLocation:CGPoint){
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func boundsCheckZombie(){
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if self.zombie!.position.x <= bottomLeft.x {
            self.zombie!.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if self.zombie!.position.x >= topRight.x {
            self.zombie!.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if self.zombie!.position.y <= bottomLeft.y {
            self.zombie!.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if self.zombie!.position.y >= topRight.y {
            self.zombie!.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    func rotateSprite(sprite: SKSpriteNode,direction:CGPoint,rotateRadiansPerSec:CGFloat){
        let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt),abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect)-enemy.size.height/2))
        addChild(enemy)
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove,actionRemove]))
     
        
    }
    func startZombieAnimation(){
        if self.zombie!.actionForKey("animation")==nil{
            self.zombie!.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    func stopZombieAnimation(){
        self.zombie!.removeActionForKey("animation")
    }
    func spawnCat(){
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        cat.zRotation = -π / 16.0
        
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle,rightWiggle])

        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        let group = SKAction.group([fullScale,fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let actions = [appear,groupWait,disappear,removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    func zombieHitCat(cat:SKSpriteNode){
        runAction(catCollisionSound)
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        cat.runAction(turnGreen)
    }
    func zombieHitEnemy(enemy:SKSpriteNode){
        runAction(enemyCollisionSound)
        
        invincible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock() {
            self.zombie!.hidden = false
            self.invincible = false
        }
        zombie!.runAction(SKAction.sequence([blinkAction, setHidden]))
        

    }
    func checkCollisions(){
        var hitCats:[SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie!.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if self.invincible {
            return
        }
        
        var hitEnemies :[SKSpriteNode]=[]
        enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie!.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveTrain() {
        var targetPosition = self.zombie!.position
        enumerateChildNodesWithName("train") { node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
    }
    
}