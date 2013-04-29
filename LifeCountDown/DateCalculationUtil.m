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

    if (myDict != nil) {
        [self calcYearBase:myDict];

        if ([myDict objectForKey:@"birthDate"] != nil) {
            self.birthDate = [myDict objectForKey:@"birthDate"];

            //NSLog(@"birthDate %@",  birthDate);
            [self updateAge:birthDate];
        }
    }

    return self;
}

// Calculates number of years to live based on user-entered criteria
- (void)calcYearBase:(NSDictionary*)completedDict {
    if (completedDict != nil && [completedDict objectForKey:@"gender"] != nil) {
        if ([[completedDict objectForKey:@"gender"] isEqualToString:@"m"]) {
            yearBase = MALE_AGE_START;
            totalSecondsInLife = ((((365.25 * MALE_AGE_START) * 24) * 60) * 60);
        }
        else if ([[completedDict objectForKey:@"gender"] isEqualToString:@"f"]) {
            yearBase = FEMALE_AGE_START;
            totalSecondsInLife = ((((365.25 * FEMALE_AGE_START) * 24) * 60) * 60);
        }

        futureAgeStr = [NSString stringWithFormat:@"You will be...%d", yearBase];
    }
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(NSDate*)dateArg {
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit |
                    NSMinuteCalendarUnit | NSSecondCalendarUnit;

    // Calculate difference between current date and user's birth date to get their age
    if (birthDate != nil)
        currentAgeDateComp = [calendar components:unitFlags fromDate:dateArg  toDate:[NSDate date]  options:0];

    // Subtract current age from estimated expiration age, to find years remaining to live
    if (currentAgeDateComp != nil)
        [self calculateSeconds:birthDate];
}

// Calculate the user's remaining minutes left to live
- (void)calculateSeconds:(NSDate*)dateArg {

    if (calendar != nil) {
        // Obtain date components representing the difference from the user's birthday until now
        NSDateComponents *bdayComp = [calendar components:unitFlags fromDate:dateArg];
        NSDateComponents *comps = [[NSDateComponents alloc] init]; // Obtain empty date components to set, so we have a static starting point
        comps.calendar = calendar; // Set its calendar to our Gregorian calendar
        [comps setDay:[bdayComp day]];
        [comps setMonth:[bdayComp month]];
        [comps setYear:[bdayComp year] + yearBase];

        // Now obtain the number of seconds from our static starting point, comps, and now
        secondsRemaining = [[calendar dateFromComponents:comps] timeIntervalSinceNow];
    }
}

@end