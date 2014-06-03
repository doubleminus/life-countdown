/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 PWProgressView.m
 
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

#import "PWProgressView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat PWCenterHoleInsetRatio             = 0.2f;
static const CGFloat PWProgressShapeInsetRatio          = 0.03f;
static const CGFloat PWDefaultAlpha                     = 0.9f;
static const CGFloat PWScaleAnimationScaleFactor        = 2.3f;
static const CFTimeInterval PWScaleAnimationDuration    = 0.5;

@interface PWProgressView ()

@property (nonatomic, strong) CAShapeLayer *boxShape;
@property (nonatomic, strong) CAShapeLayer *progressShape;

@end

@implementation PWProgressView

- (instancetype)init { return [self initWithFrame:CGRectZero]; }

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.alpha = PWDefaultAlpha;

        self.boxShape = [CAShapeLayer layer];
        self.boxShape.fillColor         = [UIColor blackColor].CGColor;
        self.boxShape.anchorPoint       = CGPointMake(0.5f, 0.5f);
        self.boxShape.contentsGravity   = kCAGravityCenter;
        self.boxShape.fillRule          = kCAFillRuleEvenOdd;

        self.progressShape = [CAShapeLayer layer];
        self.progressShape.fillColor   = [UIColor clearColor].CGColor;
        self.progressShape.strokeColor = [UIColor blackColor].CGColor;

        [self.layer addSublayer:self.boxShape];
        [self.layer addSublayer:self.progressShape];

        // Add three labels: LIFE X% REMAINING
        _lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(19, -14, 40, 40)];
        _lbl1.text = @"Life";
        _lbl1.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11.0];
        _lbl1.textColor = [UIColor whiteColor];
        _lbl1.alpha = .9;
        [self addSubview:_lbl1];

        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 24, 50, 11)];
        _percentLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11.0];
        _percentLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha: 1.0];
        _percentLabel.alpha = .9;
        [self addSubview:_percentLabel];

        _lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(1, 31, 60, 40)];
        _lbl2.text = @"Remaining";
        _lbl2.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:10.3];
        _lbl2.textColor = [UIColor whiteColor];
        _lbl2.alpha = .9;
        [self addSubview:_lbl2];

        // Reposition and resize labels for iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _lbl1.frame = CGRectMake(25, -17, 50, 50);
            _percentLabel.frame = CGRectMake(20, 13, 70, 50);
            _lbl2.frame = CGRectMake(6, 43, 75, 50);

            _lbl1.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0];
            _percentLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0];
            _lbl2.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:12.3];
        }
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat centerHoleInset     = PWCenterHoleInsetRatio * CGRectGetWidth(self.bounds);
    CGFloat progressShapeInset  = PWProgressShapeInsetRatio * CGRectGetWidth(self.bounds);

    CGRect pathRect = CGRectMake(CGPointZero.x,
                                 CGPointZero.y,
                                 CGRectGetWidth(self.bounds),
                                 CGRectGetHeight(self.bounds));

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:pathRect];

    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(centerHoleInset,
                                                                        centerHoleInset,
                                                                        CGRectGetWidth(self.bounds) - centerHoleInset * 2,
                                                                        CGRectGetHeight(self.bounds) - centerHoleInset * 2)
                                                cornerRadius:(CGRectGetWidth(self.bounds) - centerHoleInset * 2) / 2.0f]];

    [path setUsesEvenOddFillRule:YES];

    self.boxShape.path = path.CGPath;
    self.boxShape.bounds = pathRect;
    self.boxShape.position = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));

    CGFloat diameter = CGRectGetWidth(self.bounds) - (2 * centerHoleInset) - (2 * progressShapeInset);
    CGFloat radius = diameter / 2.0f;

    self.progressShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((CGRectGetWidth(self.bounds) / 2.0f) - (radius / 2.0f),
                                                                                 (CGRectGetHeight(self.bounds) / 2.0f) - (radius / 2.0f),
                                                                                 radius,
                                                                                 radius)
                                                         cornerRadius:radius].CGPath;

    self.progressShape.lineWidth = radius;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(CGRectGetMinX(frame),
                               CGRectGetMinY(frame),
                               CGRectGetWidth(frame),
                               CGRectGetWidth(frame))];
}

- (void)setProgress:(float)progress {
    if ([self pinnedProgress:progress] != _progress) {
        self.progressShape.strokeStart = progress;

        if (_progress == 1.0f && progress < 1.0f) {
            [self.boxShape removeAllAnimations];
        }

        _progress = [self pinnedProgress:progress];

        if (_progress == 1.0f) {
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.toValue = @(PWScaleAnimationScaleFactor);
            scaleAnimation.duration = PWScaleAnimationDuration;
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.autoreverses = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            [self.boxShape addAnimation:scaleAnimation forKey:@"transform.scale"];
        }
    }
}

- (float)pinnedProgress:(float)progress {
    float pinnedProgress = MAX(0.0f, progress);
    pinnedProgress = MIN(1.0f, pinnedProgress);

    return pinnedProgress;
}

@end
