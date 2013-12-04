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

#import "IpadControllerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateCalculationUtil.h"
#import "YLProgressBar.h"

@implementation IpadControllerViewController

NSNumberFormatter *formatter;
double totalSecondsDub, progAmount, percentRemaining;
bool exceedExp1 = NO;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // If we return from configView in landscape, then adjust UI components accordingly
    if (self.interfaceOrientation == 3 || self.interfaceOrientation == 4)
        [self handleLandscape1];

   // _progressView1.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Check to see if we already have an age value set in our plist
    //[self deletePlist];
    [self verifyPlist1];
    [self handlePortrait1];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    backgroundView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ret_ipad_hglass@2x~ipad.png"]];
    backgroundView1.frame = self.view.bounds;
    [[self view] addSubview:backgroundView1];
    [[self view] sendSubviewToBack:backgroundView1];


    // Set button colors
    [setInfoButton setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    [setInfoButton setTitleColor:[UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [setInfoButton setBackgroundColor:[UIColor whiteColor]];

    // Round button corners
    CALayer *btnLayer = [setInfoButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo1 {
    ConfigViewController *enterInfo1 = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];

    // Important to set the viewcontroller's delegate to be self
    enterInfo1.delegate = self;

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:enterInfo1 animated:YES completion:nil];
}

#pragma mark displayUserInfo Delegate function
- (void)displayUserInfo1:(NSDictionary*)infoDictionary {
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

        _ageLbl.text = [NSString stringWithFormat:@"%ld years, %ld months, %ld days old", (long)[currentAgeDateComp year], (long)[currentAgeDateComp month], (long)[currentAgeDateComp day]];

        // Calculate estimated total # of seconds to begin counting down
        seconds1 = [dateUtil secondsRemaining];
        totalSecondsDub = [dateUtil totalSecondsInLife]; // Used for calculate percent of life remaining

        if ([dateUtil secondsRemaining] > 0) {
            currAgeLbl.text = [NSString stringWithFormat:@"%.0f years old", [dateUtil yearBase]];
            exceedExp1 = NO;
            secsRem.text = @"seconds of your life remaining";
        }
        else { // Handle situation where user has exceeded maximum life expectancy
            currAgeLbl.text = @"";
            exceedExp1 = YES;
            secsRem.text = @"seconds you've outlived estimates";
        }

        if (!_timerStarted1) {
            [self updateTimerAndBar];
            [self startSecondTimer];
        }
    }
}

- (void)startSecondTimer {
    _secondTimer1 = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                    target: self
                                                  selector: @selector(updateTimerAndBar)
                                                  userInfo: nil
                                                   repeats: YES];
}

- (void)updateTimerAndBar {
    seconds1 -= 1.0;
    _cntLbl.text = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds1]];
    progAmount = seconds1 / totalSecondsDub; // Calculate here for coloring progress bar in landscape

    // Set our progress bar's value, based on amount of life remaining, but only if in landscape
    if (self.interfaceOrientation == 3 || self.interfaceOrientation == 4) {
       // [_progressView1 setProgress:progAmount];
        
        // Calculate percentage of life remaining
        percentRemaining = progAmount * 100.0;
      //  _percentLabel1.text = [NSString stringWithFormat:@"(%.8f%%)", percentRemaining];
    }

    _timerStarted1 = YES;
}
/****  END USER INFORMATION METHODS  ****/


/****  BEGIN PLIST METHODS  ****/
- (void)verifyPlist1 {
    NSError *error;
    
    // Get path to your documents directory from the list.
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path1 = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.
    //NSLog(@"path in createplistpath: %@", path);
    
    // Our plist exists, just read it.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path1]) {
        //NSLog(@"Plist file exists");
        [self readPlist1];
    }
    // There is no plist. Have the user provide info then write it to plist.
    else {
        //NSLog(@"no plist!!");
        bundle1 = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"]; // Get a path to your plist created manually in Xcode
        [[NSFileManager defaultManager] copyItemAtPath:bundle1 toPath:path1 error:&error]; // Copy this plist to your documents directory.
        [self setUserInfo1];
    }
}

- (void)readPlist1 {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;

    if (path1 != nil && path1.length > 1 && [[NSFileManager defaultManager] fileExistsAtPath:path1]) {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path1];
        _viewDict1 = (NSDictionary *)[NSPropertyListSerialization
                                     propertyListFromData:plistXML
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                     format:&format
                                     errorDescription:&errorDesc];
        // if (!_viewDict) {
        //NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        // }

        // If we have ALL of the values we need, display info to user.
        if ([_viewDict1 objectForKey:@"infoDict"] != nil) {
            DateCalculationUtil *dateUtil = [[DateCalculationUtil alloc] init];
            NSDictionary *nsdict = [_viewDict1 objectForKey:@"infoDict"];
            [dateUtil setBirthDate:[nsdict objectForKey:@"birthDate"]];
            [self displayUserInfo1:nsdict];
        }
        // Otherwise, have the user set this info
        else {
            [self setUserInfo1];
        }
    }
}

- (void)deletePlist1 {
    // For error information
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"Data.plist"];
    
    // Attempt to delete the file at filePath2
    if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    // Show contents of Documents directory for debugging purposes
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

- (NSString*)getPath1 { return self->path1; }
/**** END PLIST METHODS ****/

- (IBAction)toggleComponents1:(id)sender {
    if (currAgeLbl.hidden && _ageLbl.hidden)
        [self showComponents1];
    else
        [self handlePortrait1];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;

    if (interfaceOrientation == 1)
        [self handlePortrait1];
    else if (interfaceOrientation == 3 || interfaceOrientation == 4) // Adjust label locations in landscape right or left orientation
        [self handleLandscape1];
}

- (void)handlePortrait1 {
    setInfoButton.hidden = YES;
    currAgeLbl.hidden = YES;
    estTextLbl.hidden = YES;
  //  _percentLabel1.hidden = YES;
    ageTxtLbl.hidden = YES;
    _ageLbl.hidden = YES;
   // _progressView1.hidden = YES;
    _tchTggle.enabled = YES;
    

  //  _cntLbl.frame = CGRectMake(11,20,298,45);
//    secdsLifeRemLabel1.frame = CGRectMake(56,65,208,21);
    backgroundView1.hidden = NO;
}

- (void)handleLandscape1 {
    backgroundView1.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back4.png"]];

    _tchTggle.enabled = NO;
    currAgeLbl.hidden = YES;
    _ageLbl.hidden = YES;
    setInfoButton.hidden = YES;
    estTextLbl.hidden = YES;
    ageTxtLbl.hidden = YES;
   /*
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    if (screenRect.size.height == 568) {
        _cntLbl.frame = CGRectMake(140,70,298,85);
       // secsRem.frame = CGRectMake(185,135,208,21);
       // _progressView1.frame = CGRectMake(92,175,400,25);
       // _percentLabel1.frame = CGRectMake(82,200,400,25);
    }
    else {
        _cntLbl.frame = CGRectMake(85,60,298,85);
      //  secsRem.frame = CGRectMake(130,125,208,21);
      //  _progressView1.frame = CGRectMake(40,165,400,25);
       // _percentLabel1.frame = CGRectMake(40,190,400,25);
    } */
 /*
    if (!exceedExp1) {
        _progressView1.hidden = NO;
        _percentLabel1.hidden = NO;
        // Apply color to progress bar based on lifespan
        if (progAmount >= .66)
            _progressView1.progressTintColor = [UIColor greenColor];
        else if (progAmount && progAmount > .33)
            _progressView1.progressTintColor = [UIColor yellowColor];
        else
            _progressView1.progressTintColor = [UIColor redColor];
    } */
}

- (void)showComponents1 {
    setInfoButton.hidden = NO;
    ageTxtLbl.hidden = NO;
    currAgeLbl.hidden = NO;
    _ageLbl.hidden = NO;
    estTextLbl.hidden = NO;
    
    //NSLog(exceedExp1 ? @"Yes" : @"No");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    secsRem = nil;
    setInfoButton = nil;
    currAgeLbl = nil;
    ageTxtLbl = nil;
    estTextLbl = nil;
   // self.progressView1 = nil;
   // self.percentLabel1 = nil;
    _tchTggle = nil;
    _cntLbl = nil;
    _ageLbl = nil;
}
/* END  UI METHODS */

@end