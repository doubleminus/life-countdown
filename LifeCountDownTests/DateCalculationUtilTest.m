/*
 * DateCalculationUtilTest.m
 * LifeCountDown
 */

#import "DateCalculationUtilTest.h"
#import "DateCalculationUtil.h"

@implementation DateCalculationUtilTest

// Get number of seconds in 10 years. Make negative in order to determine age. 31,557,600 sec/yr X 10 = 315,576,000
NSInteger const SECS = ((((365.25 * 10) * 24) * 60) * -60);

// Test female age calculation
- (void)testFemaleAgeCalc {
    NSString *gender = @"f";
    Boolean stringsEqual = NO;

    // Create birthdate now, always making it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SECS];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"You will be...81";
    NSString *result = [testDateUtil futureAgeStr];
    NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is female, so expiry date should default to 81.");

    // So our subject is 10 years old and female. They should have 71 years from right now to live.
    // Let's manually calculate 71 years in seconds. 
    NSTimeInterval remSeconds = ((((365.25 * 71) * 24) * 60) * 60);
    NSInteger secResult = remSeconds - SECS;
    NSLog(@"secResult UPPER: %d", secResult);
    NSLog(@"dateUtil secondsInt UPPER: %d", [testDateUtil secondsInt]);
    STAssertEquals(secResult, [testDateUtil secondsInt], @"Remaining seconds should match.");

    // Now let's switch gender to male to see if this change is reflected in our age estimates
    gender = @"m";

    // Update our dictionary with new gender value
    testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                 forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    // Recalculate our dates via our date util
    testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Update our expected String
    expected = @"You will be...78";
    result = [testDateUtil futureAgeStr];
    //NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is now female, so expiry date should default to 78.");
}

// Test male age calculation
- (void)testMaleAgeCalc {
    NSString *gender = @"m";
    Boolean stringsEqual = NO;

    // Create birthdate now, always making it 10 years prior to the current date
    NSDate *birthDate2 = [NSDate dateWithTimeIntervalSinceNow:SECS];

    NSDictionary *testDictionary2 = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate2, gender, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    DateCalculationUtil *testDateUtil2 = [[DateCalculationUtil alloc] initWithDict:testDictionary2];

    STAssertEquals(birthDate2, [testDateUtil2 birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"You will be...78";
    NSString *result = [testDateUtil2 futureAgeStr];
    NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is male, so expiry date should default to 78.");

    // So our subject is 10 years old and male. They should have 68 years from right now to live.
    // Let's manually calculate 68 years in seconds.
    NSTimeInterval remSeconds = ((((365.25 * 68) * 24) * 60) * 60);
    NSInteger secResult = remSeconds - SECS ;
    NSLog(@"remSeconds LOWER: %f", remSeconds);
    NSLog(@"secResult LOWER: %d", secResult);
    NSLog(@"[testDateUtil secondsInt] LOWER: %d", [testDateUtil2 secondsInt]);
    STAssertEquals(secResult, [testDateUtil2 secondsInt], @"Remaining seconds should match.");

    // Now let's switch the gender to female to see if this change is reflected in our age estimates
    gender = @"f";

    // Update our dictionary with new gender value
    testDictionary2 = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate2, gender, nil]
                                                 forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    // Recalculate our dates via our date util
    testDateUtil2 = [[DateCalculationUtil alloc] initWithDict:testDictionary2];

    STAssertEquals(birthDate2, [testDateUtil2 birthDate], @"Ensure birthdate was assigned correctly.");

    // Update our expected String
    expected = @"You will be...81";
    result = [testDateUtil2 futureAgeStr];
    //NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is now female, so expiry date should default to 81.");
}

@end