//
//  MyScene.h
//  TestParticle
//
//  Created by doubleminus on 4/6/14.
//  Copyright (c) 2014 doubleminus. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

@property (strong, nonatomic) NSTimer *timey;

- (void)startSecondTimer;

@end