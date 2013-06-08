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
double weeksInYear = 52.1775, daysInAYear = 365.25;

/* Test female age calculation */
- (void)testFemaleAgeCalc {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0";

    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"Estimated final age: 81";
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
 /* ViewController *testCont = [[ViewController alloc] init];
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
    testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                 forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];
    // Recalculate our dates via date util
    testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Update expected String
    expected = @"Estimated final age: 78";
    result = [testDateUtil futureAgeStr];

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Gender is now female, so expiry age should default to 78.");

    // Now check that calculation for seconds remaining in life is correct
    remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:78];
    utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"equal");
    
    // Calculate the total seconds in a person's life who lives to 78
    totalSecondsInLife = ((((daysInAYear * 78) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

 /* Test female smoker age calculation */
- (void)testFemaleSmokerAgeCalc {
    NSInteger totalYears = 71;
    NSString *gender = @"f", *smokeStatus = @"smoker";
    
    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                             forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    NSString *expected = @"Estimated final age: 71"; // 81-10 to reflect 10 less years lived due to smoking
    NSString *result = [testDateUtil futureAgeStr];
    
    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Female smoker, so expiry age should default to 71.");
    stringsEqual = NO; // flip Boolean back for continued use during test

    // User is 10 years old and female. They should have 61 years to live if their expiry age is 71.
    // Let's manually calculate 71 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");
    
    // Calculate the total seconds in a person's life who lives to 71
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

/* Test female nonsmoker age calculation */
- (void)testFemaleNonSmokerAgeCalc {
    NSInteger totalYears = 81;
    NSString *gender = @"f", *smokeStatus = @"nonsmoker";
    
    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    NSString *expected = @"Estimated final age: 81";
    NSString *result = [testDateUtil futureAgeStr];
    
    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Female nonsmoker, so expiry age should default to 81.");
    stringsEqual = NO; // flip Boolean back for continued use during test
    
    // User is 10 years old and female. They should have 71 years to live if their expiry age is 81.
    // Let's manually calculate 81 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");
    
    // Calculate the total seconds in a person's life who lives to 81
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleSmokerAgeCalc {
    NSInteger totalYears = 68;
    NSString *gender = @"m", *smokeStatus = @"smoker";
    
    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    NSString *expected = @"Estimated final age: 68"; // 78-10 to reflect 10 less years lived due to smoking
    NSString *result = [testDateUtil futureAgeStr];
    
    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Male smoker, so expiry age should default to 68.");
    stringsEqual = NO; // flip Boolean back for continued use during test

    // User is 10 years old and male. They should have 68 years to live if their expiry age is 78.
    // Let's manually calculate 68 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");
    
    // Calculate the total seconds in a person's life who lives to 68
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalc {
    NSInteger totalYears = 78;
    NSString *gender = @"m", *smokeStatus = @"nonsmoker";
    
    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    NSString *expected = @"Estimated final age: 78";
    NSString *result = [testDateUtil futureAgeStr];

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Male nonsmoker, so expiry age should default to 78.");
    stringsEqual = NO; // flip Boolean back for continued use during test

    // User is 10 years old and male. They should have 68 years to live if their expiry age is 78.
    // Let's manually calculate 68 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");

    // Calculate the total seconds in a person's life who lives to 78
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife],
                   @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalcExercise {
    NSInteger totalYearsRemaining = 78;
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5";

    Boolean stringsEqual = NO;
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Estimated final age is 90, because exercising will add 12 years in this case
    NSString *expected = @"Estimated final age: 90";
    NSString *result = [testDateUtil futureAgeStr];

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [[[testDateUtil futureAgeStr] substringWithRange:NSMakeRange(21, 2)]integerValue];

    // 68 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add
    NSInteger minutesExInLife = (((68 * weeksInYear) * 5) * 60); // calculate total hours of exercise in 68 years more of life
    double secondsToAddFromExercise = (minutesExInLife * 6) * 60; // Totaling 12.1013 years to add to life <--- Just for reference

    if ([expected isEqualToString:result]) stringsEqual = YES;
    STAssertTrue(stringsEqual, @"Male nonsmoker, so expiry age should default to 78.");
    stringsEqual = NO; // flip Boolean back for continued use during test

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");

    // Calculate the total seconds in a person's life who lives to 90 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeInt) * 24) * 60) * 60);

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