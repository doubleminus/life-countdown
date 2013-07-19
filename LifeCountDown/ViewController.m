//
//  ViewController.m
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateCalculationUtil.h"
#import "YLProgressBar.h"
#import "HelpView.h"

@implementation ViewController

NSNumberFormatter *formatter;
double totalSecondsDub;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // If we return from configView in landscape, then adjust UI components accordingly
    if (self.interfaceOrientation == 3 || self.interfaceOrientation == 4)
        [self handleLandscape];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check to see if we already have an age value set in our plist
    //[self deletePlist];
    [self verifyPlist];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"irongrip_@2X.png"]];

    _progressView.frame = CGRectMake(25,160,280,25); // Adjust progress bar location
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo {
    ConfigViewController *enterInfo = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];

    // Important to set the viewcontroller's delegate to be self
    enterInfo.delegate = self;

    // Now present the view controller to the user
    [self presentViewController:enterInfo animated:true completion:NULL];
}

#pragma mark displayUserInfo Delegate function
- (void)displayUserInfo:(NSDictionary*)infoDictionary {
    // Perform some setup prior to setting label values...
    NSDateComponents *currentAgeDateComp;

    if (infoDictionary != nil) {
        DateCalculationUtil *dateUtil = [[DateCalculationUtil alloc] initWithDict:infoDictionary];
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGeneratesDecimalNumbers:NO];
        [formatter setMaximumFractionDigits:0];

        if ([dateUtil currentAgeDateComp] != nil)
            currentAgeDateComp = [dateUtil currentAgeDateComp];

        _currentAgeLabel.text = [NSString stringWithFormat:@"%d years, %d months, %d days old", [currentAgeDateComp year], [currentAgeDateComp month], [currentAgeDateComp day]];

        // Calculate estimated total # of seconds to begin counting down
        seconds = [dateUtil secondsRemaining];
        totalSecondsDub = [dateUtil totalSecondsInLife]; // Used for calculate percent of life remaining

        if ([dateUtil secondsRemaining] > 0) {
            _ageLabel.text = [NSString stringWithFormat:@"%d years old", [dateUtil yearBase]];
            _progressView.hidden = NO;
        }
        // Handle situation where user has exceed life expectancy
        else {
            _ageLabel.text = @"";
            _progressView.hidden = YES;
        }

        if (!timerStarted) {
            [self updateTimerAndBar];
            [self startSecondTimer];
        }
    }
}

- (void)startSecondTimer {
    secondTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                   target: self
                                                 selector: @selector(updateTimerAndBar)
                                                 userInfo: nil
                                                  repeats: YES];
}

- (void)updateTimerAndBar {
    double progAmount, percentRemaining;
    seconds -= 1.0;
    _countdownLabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds]];

    // Set our progress bar's value, based on amount of life remaining
    progAmount = seconds / totalSecondsDub;
    [_progressView setProgress:progAmount];

    // Calculate percentage of life remaining
    percentRemaining = progAmount * 100.0;
    _percentLabel.text = [NSString stringWithFormat:@"(%.8f%%)", percentRemaining];

    // Apply color to progress bar based on lifespan
    if (progAmount >= .66)
        _progressView.progressTintColor = [UIColor greenColor];
    else if (progAmount && progAmount > .33)
        _progressView.progressTintColor = [UIColor yellowColor];
    else
        _progressView.progressTintColor = [UIColor redColor];

    timerStarted = YES;
}
/****  END USER INFORMATION METHODS  ****/


/****  BEGIN PLIST METHODS  ****/
- (void)verifyPlist {
    NSError *error;

    // Get path to your documents directory from the list.
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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

- (void)deletePlist {
    // For error information
    NSError *error;

    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"Data.plist"];

    // Attempt to delete the file at filePath2
    if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES) {
        //NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }

    // Show contents of Documents directory for debugging purposes
    //NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

- (NSString*)getPath {
    return self->path;
}
/**** END PLIST METHODS ****/

- (IBAction)toggleComponents:(id)sender {
    if (_currentAgeLabel.hidden && _ageLabel.hidden)
        [self showComponents];
    else
        [self handlePortrait];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;

    if (interfaceOrientation == 1)
        [self handlePortrait];
    // Adjust label locations in landscape right or Left orientation
    else if (interfaceOrientation == 3 || interfaceOrientation == 4)
        [self handleLandscape];
}

- (void)handlePortrait {
    iButton.hidden = YES;
    estTxtLbl.hidden = YES;
    currAgeTxtLbl.hidden = YES;
    _percentLabel.hidden = NO;
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;

    _countdownLabel.frame = CGRectMake(11,20,298,85);
    secdsLifeRemLabel.frame = CGRectMake(56,84,208,21);
    _progressView.frame = CGRectMake(25,160,280,25);
    
    [_touchToggle setEnabled:YES];
    [_setInfoSwipe setEnabled:YES];
}

- (void)handleLandscape {
    [_touchToggle setEnabled:NO];
    [_setInfoSwipe setEnabled:NO];
    iButton.hidden = YES;
    estTxtLbl.hidden = YES;
    currAgeTxtLbl.hidden = YES;
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;
    _percentLabel.hidden = YES;

    _countdownLabel.frame = CGRectMake(135,70,298,85);
    secdsLifeRemLabel.frame = CGRectMake(185,135,208,21);
    _progressView.frame = CGRectMake(92,175,400,25);
}

- (void)showComponents {
    iButton.hidden = NO;
    estTxtLbl.hidden = NO;
    currAgeTxtLbl.hidden = NO;
    _currentAgeLabel.hidden = NO;
    _ageLabel.hidden = NO;
    _percentLabel.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setProgressView:nil];
    secdsLifeRemLabel = nil;
    iButton = nil;
    detailsLabel = nil;
    [self setPercentLabel:nil];
    [self setCountdownLabel:nil];
    [self setAgeLabel:nil];
    [self setDateLabel:nil];
    [self setCurrentAgeLabel:nil];
}
/* END  UI METHODS */

@end