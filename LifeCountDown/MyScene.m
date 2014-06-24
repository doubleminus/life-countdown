/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 MyScene.m
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of Nathan Wisman nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MyScene.h"

@implementation MyScene

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
    _timey = [NSTimer scheduledTimerWithTimeInterval: 22.0
                                             target: self
                                           selector: @selector(runAnimation)
                                           userInfo: nil
                                            repeats: YES];
}

- (void)runAnimation {
    [self addChild:[self newExplosion:location.x : location.y]];
}

// Particle explosion - uses MyParticle.sks
- (SKEmitterNode *)newExplosion: (float)posX : (float) posy {
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SnowParticle" ofType:@"sks"]];
    emitter.position = CGPointMake(21,200);
    emitter.name = @"explosion";
    emitter.targetNode = self.scene;
    emitter.numParticlesToEmit = 3000;
    //emitter.zPosition = 200.0;
    return emitter;
}

- (void)update:(CFTimeInterval)currentTime { /* Called before each frame is rendered */ }

@end