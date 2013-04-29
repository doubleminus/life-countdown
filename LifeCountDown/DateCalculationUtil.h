//
// DateCalculationUtil.h
// LifeCountDown
//
// Created by doubleminus on 8/18/12.
//

#import <Foundation/Foundation.h>

@interface DateCalculationUtil : NSObject

@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSString *futureAgeStr;
@property (strong, nonatomic) NSDateComponents *currentAgeDateComp;
@property NSInteger yearBase;
@property double secondsRemaining, totalSecondsInLife;

// Constructor
- (DateCalculationUtil*) initWithDict:(NSDictionary*)myDict;
- (void)calculateSeconds:(NSDate*)dateArg;

@end