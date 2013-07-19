//
//  DateCalculationUtilTest.h
//  LifeCountDown
//
//  Created by doubleminus on 9/29/12.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DateCalculationUtilTest : SenTestCase

-(double) calcCorrectRemainingSeconds:(NSDate*)bDate baseAge:(NSInteger)bAge;

@end
