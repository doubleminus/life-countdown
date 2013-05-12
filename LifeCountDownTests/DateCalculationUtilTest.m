/*
 * DateCalculationUtilTest.m
 * LifeCountDown
 */

#import "DateCalculationUtilTest.h"
#import "DateCalculationUtil.h"
#import "ViewController.h"

@implementation DateCalculationUtilTest

// Get number of seconds in 10 years. Make negative in order to determine age. 31,557,600 sec/yr X 10 = 315,576,000
double const SEC_CONST = ((((365.25 * 10) * 24) * 60) * -60);

// Test female age calculation
- (void)testFemaleAgeCalc {
    NSString *gender = @"f";
    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"You will be...81";
    NSString *result = [testDateUtil futureAgeStr];

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is female, so expiry date should default to 81.");
    stringsEqual = NO; // flip Boolean back for continued use during test

    // Our subject is 10 years old and female. They should have 71 years to live if their expiry age is 81.
    // Let's manually calculate 71 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:81];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");

    // Calculate the total seconds in a person's life who lives to 81
    double totalSecondsInLife = ((((365.25 * 81) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                  @"Total seconds in life should equal util calculation");

    // Verify that percentage label calculates and displays correctly
 /*    ViewController *testCont = [[ViewController alloc] init];
    [testCont displayUserInfo:testDictionary];

    double secsUsed = ((((365.25 * 10) * 24) * 60) * 60);
    double totalSeconds = remSeconds + secsUsed;

   float percnt = (secsUsed / totalSeconds) * 100.0;
    expected = [NSString stringWithFormat:@"%.2f%% of your life remaining", percnt];

    NSLog(@" $$$$ EXPECTED: %@", expected);
    NSLog(@" $$$$ LABEL: %@", testCont.percentLabel.text);

    if ([expected isEqualToString:testCont.percentLabel.text]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Percentage string should be correct."); */

    // Switch gender to male and keep birthdate the same, to see change in age estimate.
    gender = @"m";

    // Update dictionary with new gender
    testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                 forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    // Recalculate our dates via date util
    testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Update expected String
    expected = @"You will be...78";
    result = [testDateUtil futureAgeStr];
    //NSLog(@"result string: %@", result);

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is now female, so expiry date should default to 78.");

    // Now check that calculation for seconds remaining in life is correct
    remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:78];
    utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"equal");
    
    // Calculate the total seconds in a person's life who lives to 78
    totalSecondsInLife = ((((365.25 * 78) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

/* Helper method to calculate remaining seconds to test against */
-(double) calcCorrectRemainingSeconds:(NSDate*)bDate baseAge:(NSInteger)bAge {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit |
    NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *newComp = [calendar components:unitFlags fromDate:bDate];
   
    NSDateComponents *comps = [[NSDateComponents alloc] init]; // Obtain empty date components to set, so we have a static starting point
    comps.calendar = calendar; // Set its calendar to our Gregorian calendar
    [comps setDay:[newComp day]];
    [comps setMonth:[newComp month]];
    [comps setYear:[newComp year] + bAge];
    
    return [[calendar dateFromComponents:comps] timeIntervalSinceNow];
}

@end