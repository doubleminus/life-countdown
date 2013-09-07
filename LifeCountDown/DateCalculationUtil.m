/*
 Copyright (c) 2013, Nathan Wisman. All rights reserved.
 DateCalculationUtil.m
 
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

/*
 * This class calculates the user's current age,
 * expiration date, seconds remaining etc. based
 * on the birthdate they input.
 */

#import "DateCalculationUtil.h"

@implementation DateCalculationUtil

float const MALE_AGE_START = 75.6f, FEMALE_AGE_START = 80.7f, yearBase;
NSString *currentAgeStr;
NSDate *birthDate;
NSCalendar *calendar;
NSCalendarUnit unitFlags;

@synthesize birthDate;
@synthesize futureAgeStr;
@synthesize secondsRemaining;
@synthesize totalSecondsInLife;
@synthesize currentAgeDateComp;
@synthesize yearBase;

- (DateCalculationUtil*)initWithDict:(NSDictionary*)myDict {
    self = [super init];

    // Make sure we have our dictionary and crucial birthday value
    if (myDict != nil && [myDict objectForKey:@"birthDate"] != nil) {
        diction = myDict;
        self.birthDate = [diction objectForKey:@"birthDate"];
        yearBase = MALE_AGE_START;

        [self calculateAge:birthDate]; // 1. Calculate difference between current date and user's birthdate to get their age
        [self updateYearBase]; // 2. Adjust our base expected years to live
        [self calcBaseAgeInSeconds:yearBase]; // 3. Get this # of years in seconds

        if (currentAgeDateComp != nil)
            [self calculateSeconds:birthDate];
    }

    return self;
}

// Updates base number of years to live based on user-entered criteria
- (void)updateYearBase {
    NSString *genStr = [diction objectForKey:@"gender"], *smokeStr = [diction objectForKey:@"smokeStatus"];
    float hrsAdd = [[diction objectForKey:@"hrsExercise"] floatValue];

    if (genStr != nil && smokeStr != nil) {
        if ([genStr isEqualToString:@"f"])
            yearBase = FEMALE_AGE_START;

        if ([smokeStr isEqualToString:@"smoker"])
            yearBase -= 10.0f; // Remove 10 years from life if they smoke

        // Find # years remaining to live (diff between base years to live and current age in years)
        float yearsToLive = yearBase - [currentAgeDateComp year];

        // ~6 minutes added to your life for each MINUTE of exercise/week if you don't smoke
        if (![smokeStr isEqualToString:@"smoker"])
            minsGainedPerYear = ((hrsAdd * 60) * 6) * 52.1775; // Find hours added for each year of working out...
        else
            minsGainedPerYear = ((hrsAdd * 60) * 3) * 52.1775; // And add only 2 minutes/1 minute of exercise if smoker

        float yearsToAdd = (minsGainedPerYear * yearsToLive) / 525949.0f; // Divide by # of minutes in year
        yearBase += yearsToAdd; // We now know how many years user has to live, add yrs based on weekly exercise

        // Cap the life expectancy to academically accepted estimated max. life span for Americans
        if (yearBase > 96.0f && [genStr isEqualToString:@"f"])
            yearBase = 96.0f;
        else if (yearBase > 92.0f && [genStr isEqualToString:@"m"])
            yearBase = 92.0f;

        double secondsToAdd = (minsGainedPerYear * (yearBase - [currentAgeDateComp year])) * 60;
        totalSecondsInLife += secondsToAdd;
    }
}

- (void)calcBaseAgeInSeconds:(float)baseAgeFloat {
    totalSecondsInLife = ((((365.25 * baseAgeFloat) * 24) * 60) * 60);
}

// Determines all age information, via the user-provided birthdate
- (void)calculateAge:(NSDate*)dateArg {
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit |
                    NSMinuteCalendarUnit | NSSecondCalendarUnit;

    // Calculate difference between current date and user's birth date to get their age
    if (birthDate != nil)
        currentAgeDateComp = [calendar components:unitFlags fromDate:dateArg  toDate:[NSDate date]  options:0];

}

// Calculate the user's remaining seconds left to live
- (void)calculateSeconds:(NSDate*)dateArg {

    if (calendar != nil) {
        // Obtain date components representing the difference from the user's birthday until now
        NSDateComponents *bdayComp = [calendar components:unitFlags fromDate:dateArg];
        NSDateComponents *comps = [[NSDateComponents alloc] init]; // Obtain empty date components to set, so we have a static starting point
        [comps setCalendar:calendar]; // Set its calendar to our Gregorian calendar
        [comps setDay:[bdayComp day]];
        [comps setMonth:[bdayComp month]];
        [comps setYear:[bdayComp year] + yearBase];

        // Now obtain the number of seconds from our static starting point, comps, and now
        secondsRemaining = [[calendar dateFromComponents:comps] timeIntervalSinceNow];
    }
}

@end