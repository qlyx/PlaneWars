
//
//  MyScene.m
//  firstgame
//
//  Created by 主用户 on 16/9/7.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import "MyScene.h"

@interface MyScene()<SKPhysicsContactDelegate>
{
    int count;
}
@property (nonatomic) SKSpriteNode * airport;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

static const uint32_t bulletCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t airportCategory        =  0x1 << 2;
@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor whiteColor];
        //注意所有位置都是以左下角为原点
        
        
        // 创建飞机 只需要使用spriteNodeWithImageNamed方法，并把一副图片的名称传递进去就可以创建一个精灵
        self.airport = [SKSpriteNode spriteNodeWithImageNamed:@"airport"];
        self.airport.position = CGPointMake(self.frame.size.width/2, 10);
        [self addChild:self.airport];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        //设置物理世界大小
        self.airport.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.airport.size];
        //设为Yes表示不受重力感应
        self.airport.physicsBody.dynamic = YES;
        //该属性是一个位掩码(bitmask)。通过该属性可以将精灵分类
        self.airport.physicsBody.categoryBitMask = airportCategory;
        //检测和谁的碰撞  此处设置飞机和怪物之间的碰撞
        self.airport.physicsBody.contactTestBitMask = monsterCategory;
        self.airport.physicsBody.collisionBitMask = 0;
        //设为YES能够检测到碰撞，否则直接穿过去
        self.airport.physicsBody.usesPreciseCollisionDetection = YES;
        
    }
    return self; 
}
//添加怪物
-(void)addMonster
{
    //创建怪物
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    //计算怪物出现的位置  默认从屏幕上方20像素出出现
    int minX = 10;
    int maxX = self.frame.size.width - minX;
    int rangeX = maxX -minX;
    int actualX = (arc4random()%rangeX) + minX;
    monster.position = CGPointMake(actualX, self.frame.size.height-20);
    [self addChild:monster];
    
    int minDuration = 2.0;
    int maxDuration = 6.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 设置动作 从初始位置移动到屏幕外边，只是改变y值 从上至下 左下角为原点
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, 0) duration:actualDuration];
    //动作结束自动释放怪物
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    //检测怪物和子弹的碰撞
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = bulletCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
}


//检测碰撞
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 判断碰撞的两个物体
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & bulletCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        //子弹和怪物碰撞
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }else if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
              (secondBody.categoryBitMask & airportCategory) != 0)
    {
        //当飞机和怪物相撞
        NSLog(@"游戏结束");
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
        
        //代理通知vc游戏结束，移除动画场景
        [self.overDelegate gameOver:(SKScene *)self];
    }
}
- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
   
    //碰撞时将炮弹和怪物一起移除
    [projectile removeFromParent];
    [monster removeFromParent];
    //打中一个分数加一
    count++;
    //通知vc修改分数
    [self.overDelegate getScore:count];
}
/**
 *  通过lastSpawnTimeInterval可以记录着最近出现怪兽时的时间，而lastUpdateTimeInterval可以记录着上次更新时的时间。
 *
 *  将上次更新(update调用)的时间追加到self.lastSpawnTimeInterval中。一旦该时间大于1秒，就在场景中新增一个怪兽，并将lastSpawnTimeInterval重置
 
 该方法在画面每一帧更新的时候都会被调用。记住，该方法不会被自动调用——需要另外写一个方法来调用它
 */
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}
//Sprite Kit在显示每帧时都会调用下面的update:方法  该方法会传入当前的时间，在其中，会做一些计算，以确定出上一帧更新的时间。注意，在代码中做了一些合理性的检查，以避免从上一帧更新到现在已经过去了大量时间，并且将间隔重置为1/60秒，避免出现奇怪的行为
- (void)update:(NSTimeInterval)currentTime {
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
   
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if (location.x<self.airport.size.width/2) {
        //不让飞机跑到左边屏幕外边
        location.x = self.airport.size.width/2;
    }else if ( location.x>self.frame.size.width-self.airport.size.width/2)
    {
        //不让飞机跑到右边屏幕外边
        location.x =self.frame.size.width-self.airport.size.width/2;
    }
    //手指点哪儿飞机就跑到哪儿
    self.airport.position = CGPointMake(location.x, self.airport.position.y);
    // 创建子弹
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    //从飞机中间的位置发射出去
    projectile.position = self.airport.position;
    
    //设置精灵对应的物体，即形状
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    //Yes表明我们自己控制精灵的运动，物理引擎不能控制
    projectile.physicsBody.dynamic = YES;
    //设置精灵的类别
    projectile.physicsBody.categoryBitMask = bulletCategory;
    //设置跟谁碰撞时会通知代理
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    //collisionBitMask表示物理引擎需要处理的碰撞事件。在此处我们不希望炮弹和怪物被相互弹开——所以再次将其设置为0
    projectile.physicsBody.collisionBitMask = 0;
    //设为YES能够检测到碰撞，否则直接穿过去
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:projectile];

    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    //偏移量x只要大于屏幕即可
    //CGPoint offset2 = CGPointMake(self.size.width, offset.y*self.size.width/offset.x);
    
   // CGPoint realpoint = rwAdd(offset2, projectile.position);
    //让炮弹直着射出 x不变，y设为屏幕最上方
    SKAction * actionMove = [SKAction moveTo:CGPointMake(projectile.position.x, self.frame.size.height) duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}
@end
