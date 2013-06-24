/*
 * YLProgressBar.m
 *
 * Copyright 2012 Yannick Loriot.
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
#define YLProgressBarSizeInset              1
#define YLProgressBarSizeStripeWidth        7

// Colors
#define YLProgressBarColorBackground [UIColor colorWithRed:0.0980f green:0.1137f blue:0.1294f alpha:1.0f]
#define YLProgressBarColorBackgroundGlow [UIColor colorWithRed:0.0666f green:0.0784f blue:0.0901f alpha:1.0f]

@interface YLProgressBar () {
    UIColor* _progressTintColor;
    UIColor* _progressTintColorDark;
}

@property (nonatomic, assign) double progressOffset;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (strong, nonatomic) NSTimer* animationTimer;

/** Init the progress bar. */
- (void)initializeProgressBar;

/** Build the stripes. */
- (UIBezierPath *)stripeWithOrigin:(CGPoint)origin bounds:(CGRect)frame;

/** Draw the background (track) of the slider. */
- (void)drawBackgroundWithRect:(CGRect)rect;
/** Draw the progress bar. */
- (void)drawProgressBarWithRect:(CGRect)rect;
/** Draw the stipes into the given rect. */
- (void)drawStripesWithRect:(CGRect)rect;

@end

@implementation YLProgressBar
@synthesize progressOffset, cornerRadius, animationTimer;
@synthesize animated;

-(id)initWithFrame:(CGRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self initializeProgressBar];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self initializeProgressBar];
}

- (void)drawRect:(CGRect)rect {
    // Refresh the corner radius value
    self.cornerRadius = rect.size.height / 2;

    // Compute the progressOffset for the animation
    self.progressOffset = (self.progressOffset > 2 * YLProgressBarSizeStripeWidth - 1) ? 0 : ++self.progressOffset;

    // Draw the background track
    [self drawBackgroundWithRect:rect];

    if (self.progress > 0) {
        CGRect innerRect = CGRectMake(YLProgressBarSizeInset,
                                      YLProgressBarSizeInset,
                                      rect.size.width * self.progress - 2 * YLProgressBarSizeInset, 
                                      rect.size.height - 2 * YLProgressBarSizeInset);

        [self drawProgressBarWithRect:innerRect]; // Controls color
        [self drawStripesWithRect:innerRect]; // Stripes
    }
}

- (void)setProgressTintColor:(UIColor *)aProgressTintColor {
    _progressTintColor = aProgressTintColor;
    const CGFloat* components = CGColorGetComponents(_progressTintColor.CGColor);
    _progressTintColorDark = [UIColor colorWithRed:components[0] / 4.0f
                                       green:components[1] / 4.0f
                                       blue:components[2] / 4.0f
                                       alpha:CGColorGetAlpha(_progressTintColor.CGColor)];
}

- (UIColor*)progressTintColor {
    if (!_progressTintColor) {
        [self setProgressTintColor:[UIColor greenColor]];
    }
    return _progressTintColor;
}

#pragma mark -
#pragma mark YLProgressBar Public Methods

- (void)setAnimated:(BOOL)_animated {
    animated = _animated;

    if (animated) {
        if (self.animationTimer == nil) {
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30 
                                                                   target:self 
                                                                 selector:@selector(setNeedsDisplay)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }
    }
    else {
        if (self.animationTimer && [animationTimer isValid]) {
            [animationTimer invalidate];
        }

        self.animationTimer = nil;
    }
}

#pragma mark YLProgressBar Private Methods

- (void)initializeProgressBar {
    self.progressOffset = 0;
    self.animationTimer = nil;
    self.animated = YES;
}

- (UIBezierPath *)stripeWithOrigin:(CGPoint)origin bounds:(CGRect)frame {
    float height = frame.size.height;
    UIBezierPath *rect = [UIBezierPath bezierPath];

    [rect moveToPoint:origin];
    [rect addLineToPoint:CGPointMake(origin.x + YLProgressBarSizeStripeWidth, origin.y)];
    [rect addLineToPoint:CGPointMake(origin.x + YLProgressBarSizeStripeWidth - 8, origin.y + height)];
    [rect addLineToPoint:CGPointMake(origin.x - 8, origin.y + height)];
    [rect addLineToPoint:origin];
    [rect closePath]; 

    return rect;
}

- (void)drawBackgroundWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context); {
        // Draw the white shadow
        [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2] set];

        UIBezierPath* shadow = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5, 0, rect.size.width - 1, rect.size.height - 1)
                                                          cornerRadius:cornerRadius];
        [shadow stroke];

        // Draw the track
        [YLProgressBarColorBackground set];

        UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height-1) cornerRadius:cornerRadius];
        [roundedRect fill];

        // Draw the inner glow
        [YLProgressBarColorBackgroundGlow set];

        CGMutablePathRef glow = CGPathCreateMutable();
        CGPathMoveToPoint(glow, NULL, cornerRadius, 0);
        CGPathAddLineToPoint(glow, NULL, rect.size.width - cornerRadius, 0);
        CGContextAddPath(context, glow);
        CGContextDrawPath(context, kCGPathStroke);
        CGPathRelease(glow);
    }
    CGContextRestoreGState(context);
}

- (void)drawProgressBarWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context); {
        UIBezierPath *progressBounds = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        CGContextAddPath(context, [progressBounds CGPath]);
        CGContextClip(context);

        CGFloat locations[] = {0.0, 1.0};
        CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:(id)_progressTintColorDark.CGColor,
                                          (id)self.progressTintColor.CGColor, 
                                          nil];
        
        CGGradientRef gradient = CGGradientCreateWithColors (colorSpace, colors, locations);
        
        CGContextDrawLinearGradient(context, gradient, CGPointMake(rect.origin.x, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y), (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
        
        CGGradientRelease(gradient);
    }

    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawStripesWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();

    CGContextSaveGState(context); {
        UIBezierPath *allStripes = [UIBezierPath bezierPath];

        for (int i = 0; i <= rect.size.width / (2 * YLProgressBarSizeStripeWidth) + (2 * YLProgressBarSizeStripeWidth); i++) {
            UIBezierPath* stripe = [self stripeWithOrigin:CGPointMake(i * 2 * YLProgressBarSizeStripeWidth + self.progressOffset, YLProgressBarSizeInset)
                                                   bounds:rect];
            [allStripes appendPath:stripe];
        }
        
        // Clip the progress frame
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];

        CGContextAddPath(context, [clipPath CGPath]);
        CGContextClip(context);
        
        CGContextSaveGState(context); {
            // Clip the stripes
            CGContextAddPath(context, [allStripes CGPath]);
            CGContextClip(context);
            
            const CGFloat stripesColorComponents[] = { 0.0f, 0.0f, 0.0f, 0.28f };
            CGColorRef stripesColor = CGColorCreate(colorSpace, stripesColorComponents);
            
            CGContextSetFillColorWithColor(context, stripesColor);
            CGContextFillRect(context, rect);
            CGColorRelease(stripesColor);
        }
        CGContextRestoreGState(context);
    }

    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
}

@end
