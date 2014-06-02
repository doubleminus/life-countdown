/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
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
UIToolbar* mainToolbar; // Used for first app run only
double totalSecondsDub, progAmount, percentRemaining;
bool exceedExp1 = NO;
ConfigViewController *enterInfo1;
DateCalculationUtil *dateUtil;
FileHandler *fileHand;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadUserData];

    if (enterInfo1 == nil) {
        enterInfo1 = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];
        enterInfo1.delegate = self;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:enterInfo1 animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handlePortrait1];
    fileHand = [[FileHandler alloc] init];
    dateUtil = [[DateCalculationUtil alloc] init];

    backgroundView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ret_ipad_hglass@2x.png"]];
    backgroundView1.frame = self.view.bounds;
    [[self view] addSubview:backgroundView1];
    [[self view] sendSubviewToBack:backgroundView1];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    // Set up our formatter, to be used in displayUserInfo:(NSDictionary*)infoDictionary method
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGeneratesDecimalNumbers:NO];
    [formatter setMaximumFractionDigits:0];
}

- (void)loadUserData {
    // Get dictionary of user data from our file handler. If dictionary is nil, request config data from user
    NSDictionary *nsdict;

    if (nsdict == nil) {
        nsdict = [fileHand readPlist];
    }

    if (nsdict) {
        [self displayUserInfo:nsdict];
    }
    else {
        [self firstTimeUseSetup];
    }
}

- (void)firstTimeUseSetup {
    _cntLbl.hidden = YES;
    secsRem.hidden = YES;

    enterInfo1 = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];
    enterInfo1.delegate = self; // Important to set the viewcontroller's delegate to be self

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:enterInfo1 animated:NO completion:nil];

    self.view.backgroundColor = [UIColor clearColor];
    mainToolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    mainToolbar.barStyle = UIBarStyleDefault;
    [self.view.superview insertSubview:mainToolbar belowSubview:enterInfo1.view];
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo:(id)sender {
    if (mainToolbar.superview) {
        [mainToolbar removeFromSuperview];
    }

    [enterInfo1 animateConfig:nil];
}

#pragma mark displayUserInfo Delegate function
- (void)displayUserInfo:(NSDictionary*)infoDictionary {
    // Perform some setup prior to setting label values...
    NSDateComponents *currentAgeDateComp;

    if (infoDictionary != nil) {
        [mainToolbar removeFromSuperview];

        [dateUtil beginAgeProcess:infoDictionary];

        if ([dateUtil currentAgeDateComp] != nil) {
            currentAgeDateComp = [dateUtil currentAgeDateComp];
        }

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

    [self showComponents1];
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

    _timerStarted1 = YES;
}
/****  END USER INFORMATION METHODS  ****/

- (void)showComponents1 {
    secsRem.hidden       = NO;
    setInfoButton.hidden = NO;
    ageTxtLbl.hidden     = NO;
    currAgeLbl.hidden    = NO;
    estTextLbl.hidden    = NO;
    _ageLbl.hidden       = NO;
    _cntLbl.hidden       = NO;

    //NSLog(exceedExp1 ? @"Yes" : @"No");
}

- (void)handlePortrait1 {
    secsRem.hidden       = YES;
    setInfoButton.hidden = YES;
    currAgeLbl.hidden    = YES;
    estTextLbl.hidden    = YES;
    ageTxtLbl.hidden     = YES;
    _pLabel.hidden       = YES;
    _ageLbl.hidden       = YES;
    _progBar.hidden      = YES;
    _cntLbl.hidden       = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    secsRem       = nil;
    setInfoButton = nil;
    currAgeLbl    = nil;
    ageTxtLbl     = nil;
    estTextLbl    = nil;
    _progBar      = nil;
    _pLabel       = nil;
    _cntLbl       = nil;
    _ageLbl       = nil;
}
/* END  UI METHODS */

@end