/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 ConfigViewController.m
 
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

#import "BackgroundLayer.h"

@implementation BackgroundLayer

// Dark grey gradient background for ConfigViewController.view
+ (CAGradientLayer*) greyGradient {
    UIColor *colorOne   = [UIColor colorWithWhite:0.8 alpha:1.0];
    UIColor *colorTwo   = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.4 alpha:1.0];
    UIColor *colorThree = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.3 alpha:1.0];
    UIColor *colorFour  = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.6 alpha:1.0];
    UIColor *colorFive  = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.2 alpha:1.0];
    
    NSArray  *colors    = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, colorFive.CGColor, nil];
    NSNumber *stopOne   = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo   = [NSNumber numberWithFloat:0.25];
    NSNumber *stopThree = [NSNumber numberWithFloat:0.50];
    NSNumber *stopFour  = [NSNumber numberWithFloat:0.75];
    NSNumber *stopFive  = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, stopFive, nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.cornerRadius = 15.0f;
    
    return headerLayer;
}

// Lighter grey gradient background for landscape view
+ (CAGradientLayer*) greyGradient2 {
    UIColor *colorOne   = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.2 alpha:1.0];
    UIColor *colorTwo   = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.4 alpha:1.0];
    UIColor *colorThree = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.3 alpha:1.0];
    UIColor *colorFour  = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.4 alpha:1.0];
    
    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];
    
    NSNumber *stopOne   = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo   = [NSNumber numberWithFloat:0.333];
    NSNumber *stopThree = [NSNumber numberWithFloat:0.666];
    NSNumber *stopFour  = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
}

@end