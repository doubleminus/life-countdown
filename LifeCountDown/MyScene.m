//
//  MyScene.m
//  TestParticle
//
//  Created by doubleminus on 4/6/14.
//  Copyright (c) 2014 doubleminus. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

NSTimer *timey;
CGPoint location;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup scene here */
        self.backgroundColor = [SKColor clearColor];
    }

    location = CGPointMake(0, 0);

    [self runAnimation];
    [self startSecondTimer];
    
    return self;
}

- (void)startSecondTimer {
    timey = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                             target: self
                                           selector: @selector(runAnimation)
                                           userInfo: nil
                                            repeats: YES];
}

- (void)runAnimation {
    // Add effect at touch location
    [self addChild:[self newExplosion:location.x : location.y]];
}

// Particle explosion - uses MyParticle.sks
- (SKEmitterNode *)newExplosion: (float)posX : (float) posy {
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"RainParticle" ofType:@"sks"]];
    emitter.position = CGPointMake(50,50);
    emitter.name = @"explosion";
    emitter.targetNode = self.scene;
    emitter.numParticlesToEmit = 1000;
    emitter.zPosition=2.0;
    return emitter;
}

- (void)update:(CFTimeInterval)currentTime { /* Called before each frame is rendered */ }

@end