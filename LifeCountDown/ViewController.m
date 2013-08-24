/*
 Copyright (c) 2013, Nathan Wisman. All rights reserved.
 ViewController.m
 
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

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateCalculationUtil.h"
#import "YLProgressBar.h"

@implementation ViewController

NSNumberFormatter *formatter;
double totalSecondsDub, progAmount, percentRemaining;

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

    _progressView.hidden = YES;
    _percentLabel.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self handlePortrait];
    [backgroundView setFrame:self.view.bounds];
    [[self view] addSubview:backgroundView];
    [[self view] sendSubviewToBack:backgroundView];
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo {
    ConfigViewController *enterInfo = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];

    // Important to set the viewcontroller's delegate to be self
    enterInfo.delegate = self;

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    enterInfo.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:enterInfo animated:true completion:nil];
   // self.modalPresentationStyle = UIModalPresentationFullScreen;

     // enterInfo.view.alpha = .8;
  //  enterInfo.view.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1];
   // label.text = @”This is good!”;
   // [UIView animateWithDuration:3.0 animations:^{enterInfo.view.alpha = 1.f; }];
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

        if ([dateUtil secondsRemaining] > 0)
            _ageLabel.text = [NSString stringWithFormat:@"%d years old", [dateUtil yearBase]];
        else  // Handle situation where user has exceeded maximum life expectancy
            _ageLabel.text = @"";

        if (!_timerStarted) {
            [self updateTimerAndBar];
            [self startSecondTimer];
        }
    }
}

- (void)startSecondTimer {
    _secondTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                   target: self
                                                 selector: @selector(updateTimerAndBar)
                                                 userInfo: nil
                                                  repeats: YES];
}

- (void)updateTimerAndBar {
    seconds -= 1.0;
    _countdownLabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
    progAmount = seconds / totalSecondsDub; // Calculate here for coloring progress bar in landscape

    // Set our progress bar's value, based on amount of life remaining, but only if in landscape
    if (self.interfaceOrientation == 3 || self.interfaceOrientation == 4) {
        [_progressView setProgress:progAmount];

        // Calculate percentage of life remaining
        percentRemaining = progAmount * 100.0;
        _percentLabel.text = [NSString stringWithFormat:@"(%.8f%%)", percentRemaining];
    }

    _timerStarted = YES;
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
    _percentLabel.hidden = YES;
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;
    _progressView.hidden = YES;
    _touchToggle.enabled = YES;
    _setInfoSwipe.enabled = YES;

    _countdownLabel.frame = CGRectMake(11,0,298,45);
    secdsLifeRemLabel.frame = CGRectMake(56,45,208,21);

    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hglass.jpg"]];
    backgroundView.frame = self.view.bounds;
    [[self view] addSubview:backgroundView];
    [[self view] sendSubviewToBack:backgroundView];
}

- (void)handleLandscape {
    self.view.backgroundColor = [UIColor blackColor];
    _touchToggle.enabled = NO;
    _setInfoSwipe.enabled = NO;
    _percentLabel.hidden = NO;
    _progressView.hidden = NO;
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;
    backgroundView.hidden = YES;
    iButton.hidden = YES;
    estTxtLbl.hidden = YES;
    currAgeTxtLbl.hidden = YES;

    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    if (screenRect.size.height == 568) {
        _countdownLabel.frame = CGRectMake(140,70,298,85);
        _progressView.frame = CGRectMake(92,175,400,25);
        secdsLifeRemLabel.frame = CGRectMake(185,135,208,21);
    }
    else {
        _countdownLabel.frame = CGRectMake(90,70,298,85);
        _progressView.frame = CGRectMake(50,175,400,25);
        secdsLifeRemLabel.frame = CGRectMake(130,135,208,21);
    }

    // Apply color to progress bar based on lifespan
    if (progAmount >= .66)
        _progressView.progressTintColor = [UIColor greenColor];
    else if (progAmount && progAmount > .33)
        _progressView.progressTintColor = [UIColor yellowColor];
    else
        _progressView.progressTintColor = [UIColor redColor];
}

- (void)showComponents {
    iButton.hidden = NO;
    estTxtLbl.hidden = NO;
    currAgeTxtLbl.hidden = NO;
    _currentAgeLabel.hidden = NO;
    _ageLabel.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    secdsLifeRemLabel = nil;
    iButton = nil;
    detailsLabel = nil;
    self.progressView = nil;
    self.percentLabel = nil;
    self.countdownLabel = nil;
    self.ageLabel = nil;
    self.dateLabel = nil;
    self.dateLabel = nil;
    self.currentAgeLabel = nil;
}
/* END  UI METHODS */

@end