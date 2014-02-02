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
NSString *msg = @"Total seconds in life should equal util calculation", *bMsg = @"Ensure birthdate was assigned correctly.";
NSDate *birthDate;
NSArray *keyArray;

+ (void)initialize {
    if (self == [DateCalculationUtilTest class]) {
        keyArray = [NSArray arrayWithObjects: @"country", @"countryIndex", @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", nil];
        
        // Create birthdate, setting it 10 years prior to the current date
        birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    }
    // Initialization for this class and any subclasses
}

- (NSDictionary*)createDict:(NSArray*)testArr  {
    NSDictionary *testDict = [NSDictionary dictionaryWithObjects:testArr forKeys:keyArray];

    return testDict;
}

/* Test female age calculation */
- (void)testFemaleAgeCalc {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184";
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 81.0f, @"Base age should be correct");

    // Our subject is 10 years old and female. They should have 70.7 years to live if their expiry age is 80.7.
    // Let's manually calculate 70.7 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:81.0f];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 81
    double totalSecondsInLife = ((((365.25 * 81.0f) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);

    // Switch gender to male and keep birthdate the same, to see change in age estimate.
    gender = @"m";

    // Update dictionary with new gender
    testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil]
                                                  forKeys: keyArray];
    // Recalculate our dates via date util
    testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 76.0f, @"Base age should be correct");

    // Now check that calculation for seconds remaining in life is correct
    remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:76.0f];
    utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, @"equal");

    // Calculate the total seconds in a person's life who lives to 75.6
    totalSecondsInLife = ((((daysInAYear * 76.0f) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/* Test female smoker age calculation */
- (void)testFemaleSmokerAgeCalc {
    float totalYears = 71.0f;
    NSString *gender = @"f", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 71.0f, @"Base age should be correct");

    // User is 10 years old and female. They should have 60.7 years to live if their expiry age is 70.7.
    // Let's manually calculate 70.7 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 70.7
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/* Test age calculation for female smoker in Uganda */
- (void)testFemaleSmokerAgeCalcUganda {
    float totalYears = 47.0f;
    NSString *gender = @"f", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"Uganda", *countryIndex = @"184";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 47.0f, @"Base age should be correct");
    
    // User is 10 years old and female. They should have 37.0 years to live if their expiry age is 47.0.
    // Let's manually calculate 47.0 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);
    
    // Calculate the total seconds in a person's life who lives to 47.0
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/* Test U.S. female nonsmoker age calculation */
- (void)testFemaleNonSmokerAgeCalc {
    float totalYears = 81.0f;
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 81.0f, @"Base age should be correct");

    // User is 10 years old and female. They should have 70.7 years to live if their expiry age is 80.7.
    // Let's manually calculate 80.7 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 80.7
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test age calculation for a U.S. male smoker */
- (void)testMaleSmokerAgeCalc {
    float totalYears = 66.0f;
    NSString *gender = @"m", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 66.0f, @"Base age should be correct");

    // User is 10 years old and male. They should have 65.6 years to live if their expiry age is 75.6.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);
    
    // Calculate the total seconds in a person's life who lives to 65.6
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test age calculation for a male smoker in Chad */
- (void)testMaleSmokerAgeCalcChad {
    float totalYears = 40.0f;
    NSString *gender = @"m", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"Chad", *countryIndex = @"184";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 40.0f, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 65.6 years to live if their expiry age is 75.6.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);
    
    // Calculate the total seconds in a person's life who lives to 65.6
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalc {
    float totalYears = 76.0f;
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    STAssertEquals([testDateUtil yearBase], 76.0f, @"Base age should be correct");

    // User is 10 years old and male. They should have 66.0 years to live if their expiry age is 76.0.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 76.0
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalcExercise {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5", *country = @"United States", *countryIndex = @"184";;

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);

    // Estimated final age is 90, because exercising will add the maximum of 4.5 years in this case
    STAssertEquals([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    float finalAgeFloat = [testDateUtil yearBase];

    // 68 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add

    STAssertEquals([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeFloat];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 90 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeFloat) * 24) * 60) * 60);

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"20", *country = @"United States", *countryIndex = @"184";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);

    // Estimated final age should be 80.5
    STAssertEquals([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];

    // 70.5 years to live, so add 7 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 7 to get total minutes to add
    NSInteger minutesExInLife = (((70.5 * weeksInYear) * 5) * 60); // calculate total hours of exercise in 70.5 years more of life
    double secondsToAddFromExercise = (((4.5 * 365.25) * 24) * 60) * 60; //(minutesExInLife * 7) * 60; // Totaling 12.1013 years to add to life <--- Just for reference

    STAssertEquals([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 92 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = 2540386800; //((((daysInAYear * finalAgeInt) * 24) * 60) * 60);

    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
}

/*Test male age calculation */
- (void)testFemaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"20", *country = @"United States", *countryIndex = @"184";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];
    
    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);
    
    // Estimated final age should be 96, because we should hit ultimate life span cap
    STAssertEquals([testDateUtil yearBase], 85.5f, @"Base age should be correct");
    
    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];
    
    // 86 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add

    STAssertEquals([testDateUtil yearBase], 85.5f, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);

    // Calculate the total seconds in a person's life who lives to 96 (78 + 12 years added from 5 hrs exercise/week)
    //double totalSecondsInLife = ((((daysInAYear * finalAgeInt) * 24) * 60) * 60);
    
    //STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test that age calculation shows a different message for users who've outlived their life expectancy */
- (void)testOutlivedExpectancy {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5", *country = @"United States", *countryIndex = @"184";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] initWithDict:testDictionary];

    STAssertEquals(birthDate, [testDateUtil birthDate], bMsg);

    // Use this to perform math later on number of seconds left in life
    float finalAgeFloat = [testDateUtil yearBase];

    //STAssertEquals([testDateUtil yearBase], 71.0f, @"Base age should be correct");

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeFloat];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    STAssertEqualObjects(strVal1, strVal2, msg);
    
    // Calculate the total seconds in a person's life who lives to 90 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeFloat) * 24) * 60) * 60);
    
    STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], msg);
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