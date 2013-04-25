//
//  DateCalculationUtilTest.h
//  LifeCountDown
//
//  Created by doubleminus on 9/29/12.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface DateCalculationUtilTest : SenTestCase

-(double) calcCorrectRemainingSeconds:(NSDate*)bDate baseAge:(NSInteger)bAge;

@end
