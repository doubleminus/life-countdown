/*
 * This class calculates the user's current age,
 * expiration date, seconds remaining etc. based
 * on the birthdate they input.
 */

#import "DateCalculationUtil.h"

@implementation DateCalculationUtil

NSInteger const MALE_AGE_START = 78, FEMALE_AGE_START = 81, yearBase;
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
    NSString *genStr = [diction objectForKey:@"gender"];
    NSString *smokeStr = [diction objectForKey:@"smokeStatus"];
    NSInteger hrsAdd = [[diction objectForKey:@"hrsExercise"] integerValue];

    if (genStr != nil && smokeStr != nil) {
        if ([genStr isEqualToString:@"f"])
            yearBase = FEMALE_AGE_START;

        if ([smokeStr isEqualToString:@"smoker"])
            yearBase -= 10; // Remove 10 years from life if they smoke

        // Find # years remaining to live (diff between base years to live and current age in years)
        NSInteger yearsToLive = yearBase - [currentAgeDateComp year];

        // ~6 minutes added to your life for each MINUTE of exercise/week
        minsGainedPerYear = ((hrsAdd * 60) * 6) * 52.1775; // Find hours added for each year of working out...

        NSInteger yearsToAdd = (minsGainedPerYear * yearsToLive) / 525949; // Divide by # of minutes in year
        yearBase += yearsToAdd; // Now that we know how many years they have to live, we can add...
                                // ...years based on weekly exercise habits

        double secondsToAdd = (minsGainedPerYear * yearsToLive) * 60;
        totalSecondsInLife += secondsToAdd;

        futureAgeStr = [NSString stringWithFormat:@"Estimated final age: %d", yearBase];
    }
}

- (void)calcBaseAgeInSeconds:(NSInteger)baseAgeInt {
    totalSecondsInLife = ((((365.25 * baseAgeInt) * 24) * 60) * 60);
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