//
//  GameViewController.m
//  firstgame
//
//  Created by 主用户 on 16/9/7.
//  Copyright (c) 2016年 江萧. All rights reserved.
//

#import "GameViewController.h"
#import "MyScene.h"
@interface GameViewController()<GameOver>
{
    SKView * skView;
    UILabel *lb_score;
}
@end
@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    skView = [[SKView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:skView];
    lb_score = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 20)];
    lb_score.text = @"分数：0";
    lb_score.font = [UIFont systemFontOfSize:15];
    lb_score.textAlignment = NSTextAlignmentCenter;
    lb_score.textColor = [UIColor redColor];
    [skView addSubview:lb_score];
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        MyScene * scene = [MyScene sceneWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
       // scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.overDelegate = self;
        // Present the scene.
        [skView presentScene:scene];
    } 
}
- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}
-(void)gameOver:(SKScene *)scene
{
    [scene removeFromParent];
    scene = nil;
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn setTitle:@"游戏结束，点我开始" forState:0];
    [btn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [skView addSubview:btn];
}
-(void)getScore:(int)score
{
    lb_score.text = [NSString stringWithFormat:@"分数:%d",score];
}
-(void)start:(UIButton *)btn
{
    [btn removeFromSuperview];
    MyScene * scene = [MyScene sceneWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    //scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.overDelegate = self;
    lb_score.text = @"分数：0";
    // Present the scene.
    [skView presentScene:scene];
}
- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
