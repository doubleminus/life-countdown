/*
 Copyright (c) 2013, Nathan Wisman. All rights reserved.
 DateCalculationUtilTest.m
 
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

#import "DateCalculationUtilTest.h"
#import "DateCalculationUtil.h"
#import "ConfigViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DateCalculationUtilTest

// Get number of seconds in 10 years. Make negative in order to determine age. 31,557,600 sec/yr X 10 = 315,576,000
double const SEC_CONST = ((((365.25 * 10) * 24) * 60) * -60);
double weeksInYear = 52.1775, daysInAYear = 365.25;

/* Test female age calculation */
- (void)testFemaleAgeCalc {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0";
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    STAssertEquals([testDateUtil yearBase], 81, @"Base age should be correct");

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

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");

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
    STAssertEquals([testDateUtil yearBase], 78, @"Base age should be correct");

    // Now check that calculation for seconds remaining in life is correct
    remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:78];
    utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"equal");

    // Calculate the total seconds in a person's life who lives to 78
    totalSecondsInLife = ((((daysInAYear * 78) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

 /* Test female smoker age calculation */
- (void)testFemaleSmokerAgeCalc {
    NSInteger totalYears = 71;
    NSString *gender = @"f", *smokeStatus = @"smoker";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                             forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    STAssertEquals([testDateUtil yearBase], 71, @"Base age should be correct");

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
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test female nonsmoker age calculation */
- (void)testFemaleNonSmokerAgeCalc {
    NSInteger totalYears = 81;
    NSString *gender = @"f", *smokeStatus = @"nonsmoker";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    STAssertEquals([testDateUtil yearBase], 81, @"Base age should be correct");
    
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
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleSmokerAgeCalc {
    NSInteger totalYears = 68;
    NSString *gender = @"m", *smokeStatus = @"smoker";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    STAssertEquals([testDateUtil yearBase], 68, @"Base age should be correct");

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
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalc {
    NSInteger totalYears = 78;
    NSString *gender = @"m", *smokeStatus = @"nonsmoker";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    STAssertEquals([testDateUtil yearBase], 78, @"Base age should be correct");

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

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalcExercise {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5";
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Estimated final age is 90, because exercising will add 12 years in this case
    STAssertEquals([testDateUtil yearBase], 90, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];

    // 68 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add

    STAssertEquals([testDateUtil yearBase], 90, @"Base age should be correct");

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

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"20";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    // Estimated final age should be 96, because we should hit ultimate life span cap
    STAssertEquals([testDateUtil yearBase], 92, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];

    // 82 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add
   // NSInteger minutesExInLife = (((82 * weeksInYear) * 5) * 60); // calculate total hours of exercise in 68 years more of life
    //double secondsToAddFromExercise = (minutesExInLife * 6) * 60; // Totaling 12.1013 years to add to life <--- Just for reference
    
    STAssertEquals([testDateUtil yearBase], 92, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");
    
    // Calculate the total seconds in a person's life who lives to 92 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeInt) * 24) * 60) * 60);
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testFemaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"20";
    //NSLog(@"SEC_CONST constant: %f", SECS);

    // Create birthdate, setting it 10 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    // Estimated final age should be 96, because we should hit ultimate life span cap
    STAssertEquals([testDateUtil yearBase], 96, @"Base age should be correct");
    
    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];
    
    // 86 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add

    STAssertEquals([testDateUtil yearBase], 96, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, @"Remaining seconds in life should be equal");
    
    // Calculate the total seconds in a person's life who lives to 96 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeInt) * 24) * 60) * 60);
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test that age calculation shows a different message for users who've outlived their life expectancy */
- (void)testOutlivedExpectancy {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5";
    //NSLog(@"SEC_CONST constant: %f", SECS);
    
    // Create birthdate, setting it 100 years prior to the current date
    NSDate *birthDate = [NSDate dateWithTimeIntervalSinceNow:((((365.25 * 100) * 24) * 60) * -60)];

    NSDictionary *testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, hrsExercise, nil]
                                                               forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil]];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];

    STAssertEquals([testDateUtil yearBase], 75, @"Base age should be correct");

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
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
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