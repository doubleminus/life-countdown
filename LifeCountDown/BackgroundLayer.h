//
//  BackgroundLayer.h
//  Life Count
//
//  Created by Nathan Wisman on 2/21/14.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) blueGradient;

@end