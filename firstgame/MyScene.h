//
//  MyScene.h
//  firstgame
//
//  Created by 主用户 on 16/9/7.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@protocol GameOver <NSObject>

-(void)gameOver:(SKScene *)scene;
-(void)getScore:(int)score;
@end
@interface MyScene : SKScene

@property (nonatomic,weak) id<GameOver> overDelegate;
@end
