//
//  ViewController.m
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DateCalculationUtil.h"

@implementation ViewController

@synthesize currentAgeLabel = _currentAgeLabel;
@synthesize dateLabel = _dateLabel;
@synthesize ageLabel = _ageLabel;
@synthesize youAreLabel = _youAreLabel;
@synthesize countdownLabel = _countdownLabel;
@synthesize viewDict = _viewDict;

NSNumberFormatter *formatter;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Check to see if we already have an age value set in our plist
    //[self deletePlist];
    [self verifyPlist];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo {
    ConfigViewController* enterInfo = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];

    // Important to set the viewcontroller's delegate to be self
    enterInfo.delegate = self;

    // Now present the view controller to the user
    [self presentViewController:enterInfo animated:true completion:NULL];
}

#pragma mark displayUserInfo Delegate function

// Display the amount in the text field
- (void)displayUserInfo:(NSDictionary*)infoDictionary {
    // Perform some setup prior to setting label values...
    NSDateComponents *currentAgeDateComp;

    if (infoDictionary != nil) {
        DateCalculationUtil *dateUtil = [[DateCalculationUtil alloc] initWithDict:infoDictionary];
        _youAreLabel.text = @"You are...";
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

        if ([dateUtil currentAgeDateComp] != nil)
            currentAgeDateComp = [dateUtil currentAgeDateComp];

        _currentAgeLabel.text = [NSString stringWithFormat:@"%d years, %d months, %d days old", [currentAgeDateComp year], [currentAgeDateComp month], [currentAgeDateComp day]];

        if ([dateUtil futureAgeStr] != nil)
            _ageLabel.text = [dateUtil futureAgeStr];

        [self writePlist:infoDictionary];

        // Calculate total # of seconds to begin counting down
        seconds = [dateUtil secondsInt];

        if (!timerStarted) {
            [self updateTimer];
            [self startSecondTimer];
        }
    }
}

- (void)startSecondTimer {
    secondTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                   target: self
                                                 selector: @selector(updateTimer)
                                                 userInfo: nil
                                                  repeats: YES];
}

- (void)updateTimer {
    seconds -= 1;

    _countdownLabel.text = [formatter stringFromNumber:[NSNumber numberWithInt:seconds]];
    timerStarted = YES;
}
/****  END USER INFORMATION METHODS  ****/


/****  BEGIN PLIST METHODS  ****/
- (void)verifyPlist {
    NSError *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // Get path to your documents directory from the list.
    path = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.
    //NSLog(@"path in createplistpath: %@", path);

    // Our plist exists, just read it.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //NSLog(@"Plist file exists");
        [self readPlist];
    }
    // There is no plist. Have the user provide info then write it to plist.
    else {
        //NSLog(@"no plist!!");
        bundle = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]; // Get a path to your plist created manually in Xcode
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath:path error:&error]; // Copy this plist to your documents directory.
        [self setUserInfo];
    }
}

- (void)readPlist {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    if (path != nil && path.length > 1 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
        _viewDict = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!_viewDict) {
            //NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }

        // If we have ALL of the values we need, display info to user.
        if ([_viewDict objectForKey:@"infoDict"] != nil) {
            DateCalculationUtil *dateUtil = [[DateCalculationUtil alloc] init];
            NSDictionary *nsdict = [_viewDict objectForKey:@"infoDict"];
            [dateUtil setBirthDate:[nsdict objectForKey:@"birthDate"]];

            [self displayUserInfo:nsdict];
        }
        // Otherwise, have the user set this info
        else {
            [self setUserInfo];
        }
    }
}

- (void)writePlist:(NSDictionary*)infoDict {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];

    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: infoDict, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"infoDict", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];

    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        //NSLog(@"file written to path: %@", path);
    }
    /*else {
        NSLog(@"Error in writing to file: %@", error);
    }*/
}

- (void)deletePlist {
     // For error information
     NSError *error;

     // Create file mana ger
     NSFileManager *fileMgr = [NSFileManager defaultManager];

     // Point to Document directory
     NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"Data.plist"];

     // Attempt to delete the file at filePath2
     if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES) {
         NSLog(@"Unable to delete file: %@", [error localizedDescription]);
     }

     // Show contents of Documents directory
     //NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}
/**** END PLIST METHODS ****/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setCountdownLabel:nil];
    [self setYouAreLabel:nil];
    [self setAgeLabel:nil];
    [self setDateLabel:nil];
    [self setCurrentAgeLabel:nil];
}

@end