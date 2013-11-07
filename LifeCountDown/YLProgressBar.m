/*
 * YLProgressBar.m
 *
 * Copyright 2012-2013 Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "YLProgressBar.h"

// Sizes
const NSInteger YLProgressBarSizeInset = 1; //px
const NSInteger YLProgressBarStripesDelta = 8; //px

// Animation times
const NSTimeInterval YLProgressBarStripesAnimationTime = 1.0f / 30.0f; // s
const NSTimeInterval YLProgressBarProgressTime = 0.25f; // s

@interface YLProgressBar ()
@property (nonatomic, assign) double stripesOffset;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) NSTimer *stripesTimer;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSTimer *progressTargetTimer;
@property (nonatomic, assign) CGFloat progressTargetValue;

/** Init the progress bar with the default values. */
- (void)initializeProgressBar;

/** Build the stripes using the given parameters. */
- (UIBezierPath *)stripeWithOrigin:(CGPoint)origin bounds:(CGRect)frame orientation:(YLProgressBarStripesOrientation)orientation;

/** Draw the background (track) of the slider. */
- (void)drawTrack:(CGContextRef)context withRect:(CGRect)rect;
/** Draw the progress bar. */
- (void)drawProgressBar:(CGContextRef)context withRect:(CGRect)rect;
/** Draw the stipes into the given rect. */
- (void)drawStripes:(CGContextRef)context withRect:(CGRect)rect;
/** Draw the given text into the given location of the rect. */
- (void)drawText:(CGContextRef)context withRect:(CGRect)rect;

/** Callback for the setProgress:Animated: animation timer. */
- (void)updateProgressWithTimer:(NSTimer *)timer;

@end

@implementation YLProgressBar
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frameRect {
    if ((self = [super initWithFrame:frameRect]))
        [self initializeProgressBar];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]))
        [self initializeProgressBar];

    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.isHidden)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Refresh the corner radius value
    self.cornerRadius = (_type == YLProgressBarTypeRounded) ? rect.size.height / 2 : 0;
    
    // Compute the progressOffset for the stripe's animation
    self.stripesOffset = (!_stripesAnimated || self.stripesOffset > 2 * _stripesWidth - 1) ? 0 : ++self.stripesOffset;
    
    // Draw the background track
    [self drawTrack:context withRect:rect];
    
    // Draw the indicator text if necessary
    if (_indicatorTextDisplayMode == YLProgressBarIndicatorTextDisplayModeTrack)
        [self drawText:context withRect:rect];
    
    // Compute the inner rectangle
    CGRect innerRect;
    if (_type == YLProgressBarTypeRounded) {
        innerRect = CGRectMake(YLProgressBarSizeInset,
                               YLProgressBarSizeInset,
                               CGRectGetWidth(rect) * self.progress - 2 * YLProgressBarSizeInset,
                               CGRectGetHeight(rect) - 2 * YLProgressBarSizeInset);
    }
    else {
        innerRect = CGRectMake(0, 0, CGRectGetWidth(rect) * self.progress, CGRectGetHeight(rect));
    }

    if (self.progress == 0 && _behavior == YLProgressBarBehaviorIndeterminate) {
        [self drawStripes:context withRect:rect];
    }
    else if (self.progress > 0) {
        [self drawProgressBar:context withRect:innerRect];
        
        if (_stripesWidth > 0 && !_hideStripes) {
            if (_behavior == YLProgressBarBehaviorWaiting) {
                if (self.progress == 1.0f)
                    [self drawStripes:context withRect:innerRect];

            } else if (_behavior != YLProgressBarBehaviorIndeterminate) {
                [self drawStripes:context withRect:innerRect];
            }
        }
        
        // Draw the indicator text if necessary
        if (_indicatorTextDisplayMode == YLProgressBarIndicatorTextDisplayModeProgress)
            [self drawText:context withRect:innerRect];
    }
}

#pragma mark - Properties

- (CGFloat)progress {
    @synchronized (self) {
        return _progress;
    }
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setBehavior:(YLProgressBarBehavior)behavior {
    _behavior = behavior;
    
    [self setNeedsDisplay];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    progressTintColor = (progressTintColor) ? progressTintColor : [UIColor greenColor];
    
    const CGFloat *c = CGColorGetComponents(progressTintColor.CGColor);
    UIColor *leftColor = [UIColor colorWithRed:(c[0] / 2.0f) green:(c[1] / 2.0f) blue:(c[2] / 2.0f) alpha:(c[3])];
    UIColor *rightColor = progressTintColor;
    NSArray *colors = @[leftColor, rightColor];
    
    [self setProgressTintColors:colors];
}

- (void)setProgressTintColors:(NSArray *)progressTintColors {
    NSAssert(progressTintColors, @"progressTintColors must not be null");
    NSAssert([progressTintColors count], @"progressTintColors must contain at least one element");
    
    if (_progressTintColors != progressTintColors)
        _progressTintColors = progressTintColors;
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[progressTintColors count]];
    for (UIColor *color in progressTintColors) {
        [colors addObject:(id)color.CGColor];
    }
    self.colors = colors;
}

- (void)setStripesAnimated:(BOOL)animated {
    _stripesAnimated = animated;
    
    if (animated == YES) {
        if (self.stripesTimer == nil) {
            self.stripesTimer= [NSTimer timerWithTimeInterval:YLProgressBarStripesAnimationTime
                                                       target:self
                                                     selector:@selector(setNeedsDisplay)
                                                     userInfo:nil
                                                      repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_stripesTimer forMode:NSRunLoopCommonModes];
        }
    }
    else {
        if (_stripesTimer && [_stripesTimer isValid])
            [_stripesTimer invalidate];
        
        self.stripesTimer = nil;
    }
}

#pragma mark - Public Methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    @synchronized (self) {
        if (_progressTargetTimer && [_progressTargetTimer isValid])
            [_progressTargetTimer invalidate];
        
        CGFloat newProgress = progress;
        if (newProgress > 1.0f)
            newProgress = 1.0f;
        else if (newProgress < 0.0f)
            newProgress = 0.0f;
        
        if (animated) {
            _progressTargetValue = newProgress;
            CGFloat incrementValue = ((_progressTargetValue - _progress) * YLProgressBarStripesAnimationTime) / YLProgressBarProgressTime;
            self.progressTargetTimer = [NSTimer timerWithTimeInterval:YLProgressBarStripesAnimationTime
                                                               target:self
                                                             selector:@selector(updateProgressWithTimer:)
                                                             userInfo:[NSNumber numberWithFloat:incrementValue]
                                                              repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_progressTargetTimer forMode:NSRunLoopCommonModes];
        }
        else{
            _progress = newProgress;
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - Private Methods

- (void)updateProgressWithTimer:(NSTimer *)timer {
    CGFloat dt_progress = [timer.userInfo floatValue];
    _progress += dt_progress;
    
    if ((dt_progress < 0 && _progress <= _progressTargetValue)
        || (dt_progress > 0 && _progress >= _progressTargetValue)) {
        [_progressTargetTimer invalidate];
        _progressTargetTimer = nil;
        
        _progress = _progressTargetValue;
    }
    
    [self setNeedsDisplay];
}

- (void)initializeProgressBar {
    _type = YLProgressBarTypeRounded;
    _progress = 0.0f;
    _hideStripes = NO;
    _behavior = YLProgressBarBehaviorDefault;
    _stripesColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.28f];
    
    _indicatorTextLabel = [[UILabel alloc] initWithFrame:self.frame];
    _indicatorTextLabel.adjustsFontSizeToFitWidth = YES;
    _indicatorTextLabel.backgroundColor = [UIColor clearColor];
    _indicatorTextLabel.textAlignment = NSTextAlignmentRight;
    _indicatorTextLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    _indicatorTextLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:CGRectGetHeight(self.frame)];
    _indicatorTextLabel.textColor = [UIColor clearColor];
    
    _indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    
    self.trackTintColor = [UIColor blackColor];
    self.progressTintColor = self.backgroundColor;
    self.stripesOffset = 0;
    self.stripesTimer = nil;
    self.stripesAnimated = YES;
    self.stripesOrientation = YLProgressBarStripesOrientationRight;
    self.stripesWidth = YLProgressBarDefaultStripeWidth;
    self.backgroundColor = [UIColor clearColor];
}

- (UIBezierPath *)stripeWithOrigin:(CGPoint)origin bounds:(CGRect)frame orientation:(YLProgressBarStripesOrientation)orientation {
    CGFloat height = CGRectGetHeight(frame);
    UIBezierPath *rect = [UIBezierPath bezierPath];
    
    [rect moveToPoint:origin];
    
    switch (orientation) {
        case YLProgressBarStripesOrientationRight:
            [rect addLineToPoint:CGPointMake(origin.x + _stripesWidth, origin.y)];
            [rect addLineToPoint:CGPointMake(origin.x + _stripesWidth - YLProgressBarStripesDelta, origin.y + height)];
            [rect addLineToPoint:CGPointMake(origin.x - YLProgressBarStripesDelta, origin.y + height)];
            break;
        case YLProgressBarStripesOrientationLeft:
            [rect addLineToPoint:CGPointMake(origin.x - _stripesWidth, origin.y)];
            [rect addLineToPoint:CGPointMake(origin.x - _stripesWidth + YLProgressBarStripesDelta, origin.y + height)];
            [rect addLineToPoint:CGPointMake(origin.x + YLProgressBarStripesDelta, origin.y + height)];
            break;
        default:
            [rect addLineToPoint:CGPointMake(origin.x - _stripesWidth, origin.y)];
            [rect addLineToPoint:CGPointMake(origin.x - _stripesWidth, origin.y + height)];
            [rect addLineToPoint:CGPointMake(origin.x, origin.y + height)];
            break;
    }
    
    [rect addLineToPoint:origin];
    [rect closePath];
    
    return rect;
}

- (void)drawTrack:(CGContextRef)context withRect:(CGRect)rect {
    // Define the progress bar pattern to clip all the content inside
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))
                                                           cornerRadius:_cornerRadius];
    [roundedRect addClip];
    
    CGContextSaveGState(context); {
        CGFloat trackHeight = (_type == YLProgressBarTypeRounded) ? CGRectGetHeight(rect) - 1 : CGRectGetHeight(rect);
        
        // Draw the track
        [self.trackTintColor set];
        UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(rect), trackHeight) cornerRadius:_cornerRadius];
        [roundedRect fill];
        
        if (_type == YLProgressBarTypeRounded) {
            // Draw the white shadow
            [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2] set];
            
            UIBezierPath *shadow = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5f, 0, CGRectGetWidth(rect) - 1, trackHeight)
                                                              cornerRadius:_cornerRadius];
            [shadow stroke];
            
            // Draw the inner glow
            [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f] set];
            
            UIBezierPath *glow = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_cornerRadius, 0, CGRectGetWidth(rect) - _cornerRadius * 2, 1)
                                                            cornerRadius:0];
            [glow stroke];
        }
    }
    CGContextRestoreGState(context);
}

- (void)drawProgressBar:(CGContextRef)context withRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context); {
        UIBezierPath *progressBounds = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_cornerRadius];
        CGContextAddPath(context, [progressBounds CGPath]);
        CGContextClip(context);
        
        CFArrayRef colorRefs = (__bridge CFArrayRef)_colors;
        NSInteger colorCount = [_colors count];
        
        float delta = 1.0f / [_colors count];
        float semi_delta = delta / 2.0f;

        CGFloat locations[colorCount];
        for (int i = 0; i < colorCount; i++) {
            locations[i] = delta * i + semi_delta;
        }
        
        CGGradientRef gradient = CGGradientCreateWithColors (colorSpace, colorRefs, locations);
        
        CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)), CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect)), (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
        
        CGGradientRelease(gradient);
    }

    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawStripes:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSaveGState(context); {
        UIBezierPath *allStripes = [UIBezierPath bezierPath];
        
        NSInteger start = -_stripesWidth;
        int end = rect.size.width / (2 * _stripesWidth) + (2 * _stripesWidth);
        CGFloat yOffset = (_type == YLProgressBarTypeRounded) ? YLProgressBarSizeInset : 0;
        for (NSInteger i = start; i <= end; i++) {
            UIBezierPath *stripe = [self stripeWithOrigin:CGPointMake(i * 2 * _stripesWidth + _stripesOffset, yOffset)
                                                   bounds:rect
                                              orientation:_stripesOrientation];
            [allStripes appendPath:stripe];
        }
        
        // Clip the progress frame
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_cornerRadius];
        
        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        
        CGContextSaveGState(context); {
            // Clip the stripes
            CGContextAddPath(context, [allStripes CGPath]);
            CGContextClip(context);
            
            CGContextSetFillColorWithColor(context, [_stripesColor CGColor]);
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}

- (void)drawText:(CGContextRef)context withRect:(CGRect)rect {
    if (_indicatorTextLabel == nil)
        return;
    
    CGRect innerRect = CGRectMake(CGRectGetMinX(rect) + 4, CGRectGetMinY(rect) + 1, CGRectGetWidth(rect) - 8, CGRectGetHeight(rect) - 2);
    _indicatorTextLabel.frame = innerRect;
    
    if (CGRectGetWidth(innerRect) < CGRectGetHeight(innerRect) * 2.5)
        return;
    
    BOOL hasTextColor = ![_indicatorTextLabel.textColor isEqual:[UIColor clearColor]];
    if (!hasTextColor) {
        CGColorRef backgroundColor = nil;
        if (_indicatorTextDisplayMode == YLProgressBarIndicatorTextDisplayModeTrack)
            backgroundColor = _trackTintColor.CGColor ?: [UIColor blackColor].CGColor;
        else
            backgroundColor = (__bridge CGColorRef)[_colors lastObject];

        const CGFloat *components = CGColorGetComponents(backgroundColor);
        BOOL isLightBackground = (components[0] + components[1] + components[2]) / 3.0f >= 0.5f;
        
        _indicatorTextLabel.textColor = (isLightBackground) ? [UIColor blackColor] : [UIColor whiteColor];
    }
    
    BOOL hasText = (_indicatorTextLabel.text != nil);
    if (!hasText)
        _indicatorTextLabel.text = [NSString stringWithFormat:@"%.0f%%", (self.progress * 100)];
    
    [_indicatorTextLabel drawTextInRect:innerRect];
    
    if (!hasTextColor)
        _indicatorTextLabel.textColor = [UIColor clearColor];

    if (!hasText)
        _indicatorTextLabel.text = nil;
}

@end