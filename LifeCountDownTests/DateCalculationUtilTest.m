/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
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
NSDate *birthDate;
NSArray *keyArray;

+ (void)initialize {
    if (self == [DateCalculationUtilTest class]) {
        keyArray = [NSArray arrayWithObjects: @"country", @"countryIndex", @"birthDate", @"gender", @"smokeStatus", @"hrsExercise", @"hrsSit", nil];

        // Create birthdate, setting it 10 years prior to the current date
        birthDate = [NSDate dateWithTimeIntervalSinceNow:SEC_CONST];
    }
}

- (NSDictionary*)createDict:(NSArray*)testArr  {
    NSDictionary *testDict = [NSDictionary dictionaryWithObjects:testArr forKeys:keyArray];

    return testDict;
}

/* Test nonsmoker female age calculation */
- (void)testFemaleAgeCalc {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual([testDateUtil birthDate], birthDate, @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 81.0f, @"Base age should be correct");

    // Our subject is 10 years old and female. They should have 70.7 years to live if their expiry age is 80.7.
    // Let's manually calculate 70.7 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:81.0f];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 81
    double totalSecondsInLife = ((((365.25 * 81.0f) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual([testDateUtil totalSecondsInLife], totalSecondsInLife, @"Total seconds in life should equal util calculation");

    // Switch gender to male and keep birthdate the same, to see change in age estimate.
    gender = @"m";

    // Update dictionary with new gender
    testDictionary = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil]
                                                  forKeys: keyArray];
    // Recalculate our dates via date util
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual([testDateUtil birthDate], birthDate, @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 76.0f, @"Base age should be correct");

    // Now check that calculation for seconds remaining in life is correct
    remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:76.0f];
    utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"equal");

    // Calculate the total seconds in a person's life who lives to 75.6
    totalSecondsInLife = ((((daysInAYear * 76.0f) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual([testDateUtil totalSecondsInLife], totalSecondsInLife, @"Total seconds in life should equal util calculation");
}

/* Test female smoker age calculation */
- (void)testFemaleSmokerAgeCalc {
    float totalYears = 71;
    NSString *gender = @"f", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 71.0f, @"Base age should be correct");

    // User is 10 years old and female and smokes (yes, you read that right). They should have 61 years to live if their expiry age is 71.
    // Let's manually calculate 71 years in seconds.
    float remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    float utilSeconds = [testDateUtil secondsRemaining];

    // Get seconds in 71 years
    float secondsToLive = ((((71 * 365.25) * 24) * 60) * 60);

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 70.7
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test female smoker who sits too much age calculation */
- (void)testFemaleSmokerSitterAgeCalc {
    float totalYears = 71.0f;
    NSString *gender = @"f", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 71.0f, @"Base age should be correct");

    // User is 10 years old and female. They should have 60.7 years to live if their expiry age is 70.7.
    // Let's manually calculate 70.7 years in seconds.
    float remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    float utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 70.7
    float totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");

    // Now mark them as sitting 4 hours a day and check that 2 years of life have been removed
    hrsSit = @"4";

    arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    testDictionary = [self createDict:arr1];

    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual([testDateUtil yearBase], 69.0f, @"Base age should now be 71-2 years due to sitting");
    
    // Now make sitting higher than 6 hours a day to trigger 20% reduction in life expectancy
    hrsSit = @"7";
    
    arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    testDictionary = [self createDict:arr1];
    
    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 56.8f, @"Base age should now be 71-(71*.2) years due to sitting");
    
    // Now turn user to nonsmoker and calculate expectancy again
    smokeStatus = @"nonsmoker";
    
    arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    testDictionary = [self createDict:arr1];

    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 64.8f, @"Base age should now be 81-(81*.2) years due to sitting");
}

/* Test age calculation for female smoker in Uganda */
- (void)testFemaleSmokerAgeCalcUganda {
    float totalYears = 47.0f;
    NSString *gender = @"f", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"Uganda", *countryIndex = @"184", *hrsSit = @"1";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 47.0f, @"Base age should be correct");
    
    // User is 10 years old and female. They should have 37.0 years to live if their expiry age is 47.0.
    // Let's manually calculate 47.0 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");
    
    // Calculate the total seconds in a person's life who lives to 47.0
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test U.S. female nonsmoker age calculation */
- (void)testFemaleNonSmokerAgeCalc {
    float totalYears = 81.0f;
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 81.0f, @"Base age should be correct");

    // User is 10 years old and female. They should have 70.7 years to live if their expiry age is 80.7.
    // Let's manually calculate 80.7 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 80.7
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test age calculation for a U.S. male smoker */
- (void)testMaleSmokerAgeCalc {
    float totalYears = 66.0f;
    NSString *gender = @"m", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 66.0f, @"Base age should be correct");

    // User is 10 years old and male. They should have 65.6 years to live if their expiry age is 75.6.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");
    
    // Calculate the total seconds in a person's life who lives to 65.6
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test age calculation for a male smoker in Chad */
- (void)testMaleSmokerAgeCalcChad {
    float totalYears = 40.0f;
    NSString *gender = @"m", *smokeStatus = @"smoker", *hrsExercise = @"0", *country = @"Chad", *countryIndex = @"184", *hrsSit = @"1";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 40.0f, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 65.6 years to live if their expiry age is 75.6.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 65.6
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds
    
    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test male age calculation */
- (void)testMaleNonSmokerAgeCalc {
    float totalYears = 76.0f;
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"0", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    XCTAssertEqual([testDateUtil yearBase], 76.0f, @"Base age should be correct");

    // User is 10 years old and male. They should have 66.0 years to live if their expiry age is 76.0.
    // Let's manually calculate 65.6 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:totalYears];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 76.0
    double totalSecondsInLife = ((((daysInAYear * totalYears) * 24) * 60) * 60); // Days->Hours->Minutes->Seconds

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test male non-smoker age calculation */
- (void)testMaleNonSmokerAgeCalcExercise {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Estimated final age is 90, because exercising will add the maximum of 4.5 years in this case
    XCTAssertEqual([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    float finalAgeFloat = [testDateUtil yearBase];

    XCTAssertEqual([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeFloat];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 90 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeFloat) * 24) * 60) * 60);

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test male non-smoker age calculation for hitting ceiling of life expectancy from exercise */
- (void)testMaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"20", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

    // Estimated final age should be 80.5
    XCTAssertEqual([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];

    // 70.5 years to live, so add 7 minutes of life for every minute of exercise/week. 8765 hours in a year.
    //                        weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 7 to get total minutes to add
    NSInteger minutesExInLife = (((70.5 * weeksInYear) * 5) * 60); // calculate total hours of exercise in 70.5 years more of life
    double secondsToAddFromExercise = (((4.5 * 365.25) * 24) * 60) * 60; //(minutesExInLife * 7) * 60; // Totaling 12.1013 years to add to life <--- Just for reference

    XCTAssertEqual([testDateUtil yearBase], 80.5f, @"Base age should be correct");

    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];

    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];

    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 92 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = 2540386800; //((((daysInAYear * finalAgeInt) * 24) * 60) * 60);

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Test female nonsmoker age calculation for hitting ceiling of life expectancy from exercise */
- (void)testFemaleNonSmokerAgeCalcExerciseCap {
    NSString *gender = @"f", *smokeStatus = @"nonsmoker", *hrsExercise = @"20", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";
    
    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];
    
    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];
    
    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");
    
    // Estimated final age should be 96, because we should hit ultimate life span cap
    XCTAssertEqual([testDateUtil yearBase], 85.5f, @"Base age should be correct");
    
    // Use this to perform math later on number of seconds left in life
    NSInteger finalAgeInt = [testDateUtil yearBase];
    
    // 86 years to live, so add 6 minutes of life for every minute of exercise/week. 8765 hours in a year.
    // weeks remaining in life * hrs exercise/week = total hours of exercise in life. multiply this by 6 to get total minutes to add

    XCTAssertEqual([testDateUtil yearBase], 85.5f, @"Base age should be correct");
    
    // User is 10 years old and male. They should have 80 years to live if their expiry age is 90.
    // Let's manually calculate 90 years in seconds.
    double remSeconds = [self calcCorrectRemainingSeconds:birthDate baseAge:finalAgeInt];
    double utilSeconds = [testDateUtil secondsRemaining];
    
    // Cast to string for easier comparison
    NSString *strVal1 = [NSString stringWithFormat:@"%.1f", remSeconds];
    NSString *strVal2 = [NSString stringWithFormat:@"%.1f", utilSeconds];
    
    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");

    // Calculate the total seconds in a person's life who lives to 96 (78 + 12 years added from 5 hrs exercise/week)
    //double totalSecondsInLife = ((((daysInAYear * finalAgeInt) * 24) * 60) * 60);
    
    //STAssertEquals(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/*Test that age calculation shows a different message for users who've outlived their life expectancy */
- (void)testOutlivedExpectancy {
    NSString *gender = @"m", *smokeStatus = @"nonsmoker", *hrsExercise = @"5", *country = @"United States", *countryIndex = @"184", *hrsSit = @"1";

    NSArray *arr1 = [NSArray arrayWithObjects: country, countryIndex, birthDate, gender, smokeStatus, hrsExercise, hrsSit, nil];
    NSDictionary *testDictionary = [self createDict:arr1];

    DateCalculationUtil *testDateUtil = [[DateCalculationUtil alloc] init];
    [testDateUtil beginAgeProcess:testDictionary];

    XCTAssertEqual(birthDate, [testDateUtil birthDate], @"Ensure birthdate was assigned correctly.");

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
    
    XCTAssertEqualObjects(strVal1, strVal2, @"Total seconds in life should equal util calculation");
    
    // Calculate the total seconds in a person's life who lives to 90 (78 + 12 years added from 5 hrs exercise/week)
    double totalSecondsInLife = ((((daysInAYear * finalAgeFloat) * 24) * 60) * 60);

    XCTAssertEqual(totalSecondsInLife, [testDateUtil totalSecondsInLife], @"Total seconds in life should equal util calculation");
}

/* Helper method to calculate remaining seconds to test against */
- (double)calcCorrectRemainingSeconds:(NSDate*)bDate baseAge:(float)bAge {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit |
    NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *newComp = [calendar components:unitFlags fromDate:bDate];
    
    NSLog(@"bAge: %f", bAge);

    NSDateComponents *comps = [[NSDateComponents alloc] init]; // Obtain empty date components to set, so we have a static starting point
    comps.calendar = calendar; // Set its calendar to our Gregorian calendar
    [comps setDay:  [newComp day]];
    [comps setMonth:[newComp month]];
    [comps setYear: [newComp year] + bAge];
    
    return [[calendar dateFromComponents:comps] timeIntervalSinceNow];
}

@end