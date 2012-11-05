/*
 * DateCalculationUtilTest.m
 * LifeCountDown
 */

#import "DateCalculationUtilTest.h"
#import "DateCalculationUtil.h"

@implementation DateCalculationUtilTest

// Test female age calculation
- (void)testFemaleAgeCalc {
    NSString *gender = @"f";
    Boolean stringsEqual = NO;

    // Get number of seconds in 10 years. 31,557,600 sec/yr X 10 = 315,576,000
    NSTimeInterval seconds = ((((365.25 * 10) * 24) * 60) * -60);
    NSTimeInterval secs = -315576000;
    STAssertEquals(seconds, secs, @"Verify we have 10 years worth of seconds");

    // Create our birthdate now, always making it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:seconds];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"You will be...81";
    NSString *result = [testDateUtil futureAgeStr];
    NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is female, so expiry date should default to 81.");
}

// Test male age calculation
- (void)testMaleAgeCalc {
    NSString *gender = @"m";
    Boolean stringsEqual = NO;

    // Get number of seconds in 10 years. 31,557,600 sec/yr X 10 = 315,576,000
    NSTimeInterval seconds = ((((365.25 * 10) * 24) * 60) * -60);
    NSTimeInterval secs = -315576000;
    STAssertEquals(seconds, secs, @"Verify we have 10 years worth of seconds");

    // Create our birthdate now, always making it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:seconds];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"You will be...78";
    NSString *result = [testDateUtil futureAgeStr];
    NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is male, so expiry date should default to 78.");
}

@end