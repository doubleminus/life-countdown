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

#import "ViewController.h"
#import "YLProgressBar.h"
#import "ConfigViewController.h"
#import "DateCalculationUtil.h"
#import "BackgroundLayer.h"
#import "FileHandler.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation ViewController

NSNumberFormatter *formatter;
double totalSecondsDub, progAmount, percentRemaining;
CGRect phoneScrollRect;
int slideDistance2 = 0;
bool exceedExp = NO, firstTime2 = false;;
UIView *shadeView; // Used for first app run only
UIToolbar *toolbar; // Used for first app run only
ConfigViewController *enterInfo1;
DateCalculationUtil *dateUtil;
FileHandler *fileHand;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    fileHand = [[FileHandler alloc] init];
    _touchView = [_touchView init];
    
    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hglass-2.png"]];
    backgroundView.frame = self.view.bounds;
    [[self view] addSubview:backgroundView];
    [[self view] sendSubviewToBack:backgroundView];
    
    [_touchView addGestureRecognizer:_kTouch];
    [self setupHelpView];
    
    bitView.animationRepeatCount = 100;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If we return from configView in landscape, then adjust UI components accordingly
    if (self.interfaceOrientation == 3 || self.interfaceOrientation == 4) {
        [self handleLandscape];
    }
    
    _progressView.hidden = YES;
    
    // Adjust iPhone scroll rect based on screen height
    if ([[UIScreen mainScreen] bounds].size.height == 480) { // 3.5-inch
        _configBtn.frame = CGRectMake(40, 444, 31, 31);
        _tweetBtn.frame = CGRectMake(84, 448, 24, 22);
        _facebookBtn.frame = CGRectMake(123, 446, 27, 26);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadUserData];
}

- (void)loadUserData {
    // Get dictionary of user data from our file handler. If dictionary is nil, request config data from user
    NSDictionary *nsdict = [fileHand readPlist];
    
    if (nsdict) {
        [self displayUserInfo:nsdict];
    }
    else {
        [self firstTimeUseSetup];
    }
}

-(void)animateBit {
    [UIView animateWithDuration:0.5f animations:^{
        bitView.frame = CGRectOffset(bitView.frame, 0, -250);
        bitView.alpha = .8;
    }];

    bitView.hidden = YES;

    [UIView animateWithDuration:0.5f animations:^{
        bitView.frame = CGRectOffset(bitView.frame, 0, 250);
        bitView.alpha = .1;
    }];

    bitView.hidden = NO;
}

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo:(id)sender {
    enterInfo1 = [[ConfigViewController alloc]initWithNibName:@"ConfigViewController" bundle:nil];
    enterInfo1.delegate = self;

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:enterInfo1 animated:YES completion:nil];
}

#pragma mark displayUserInfo Delegate function
- (void)displayUserInfo:(NSDictionary*)infoDictionary {
    // Perform setup prior to setting label values...
    NSDateComponents *currentAgeDateComp;

    if (infoDictionary != nil) {
        // Undo first time usage setup
        _countdownLabel.hidden = NO;
        secdsLifeRemLabel.hidden = NO;

        dateUtil = [[DateCalculationUtil alloc] initWithDict:infoDictionary];
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGeneratesDecimalNumbers:NO];
        [formatter setMaximumFractionDigits:0];
        
        if ([dateUtil currentAgeDateComp] != nil) {
            currentAgeDateComp = [dateUtil currentAgeDateComp];
        }
        
        _currentAgeLabel.text = [NSString stringWithFormat:@"%ld years, %ld months, %ld days old", (long)[currentAgeDateComp year], (long)[currentAgeDateComp month], (long)[currentAgeDateComp day]];
        
        // Calculate estimated total # of seconds to begin counting down
        seconds = [dateUtil secondsRemaining];
        totalSecondsDub = [dateUtil totalSecondsInLife]; // Used for calculate percent of life remaining
        
        if ([dateUtil secondsRemaining] > 0) {
            _ageLabel.text = [NSString stringWithFormat:@"%.0f years old", [dateUtil yearBase]];
            exceedExp = NO;
            secdsLifeRemLabel.text = @"seconds of your life remaining";
        }
        else { // Handle situation where user has exceeded maximum life expectancy
            _ageLabel.text = @"";
            exceedExp = YES;
            secdsLifeRemLabel.text = @"seconds you've outlived estimates";
        }
        
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
    
    [self animateBit];
    
    _timerStarted = YES;
}
/****  END USER INFORMATION METHODS  ****/

- (void)setupHelpView {
    // Setup help view but hide it
    _helpView = [[HelpView alloc] init];
    [self.view addSubview:_helpView];

    toolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.alpha = .9;
    [self.view insertSubview:toolbar belowSubview:_helpView];
    toolbar.hidden = YES;

    // Create tap gesture for dismissing Help View
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHelp:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    [_helpView addGestureRecognizer:tap1];
}

- (IBAction)showHelp:(id)sender {
    CGRect visibleRect;

    if (_helpView && _helpView.hidden == YES) {
        visibleRect.origin = self.view.frame.origin; // Set origin to our UIScrollView's view window
        visibleRect.size = self.view.bounds.size;
        visibleRect.origin.x += 25.0;
        visibleRect.origin.y += 150.0;
        visibleRect.size.width *= .85;
        visibleRect.size.height *= .5;

        [_helpView setFrame:visibleRect];
        int tag = (int)[(UIButton *)sender tag]; // Get button tag value
        [_helpView setText:nil btnInt:tag];

        [_helpView setHidden:NO];
        [toolbar setHidden:NO];
    }
    else {
        [_helpView setHidden:YES];
        [toolbar setHidden:YES];
    }
}

- (void)firstTimeUseSetup {
    _countdownLabel.hidden = YES;
    secdsLifeRemLabel.hidden = YES;

    [self setUserInfo:nil];
}

- (IBAction)tweetTapGest:(id)sender {
    //NSLog(@"sender: %@", sender);
    int tag = (int)[(UIButton *)sender tag];
    
    NSLog(@"available for Twitter? %d", [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]);

    if ((tag == 1 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) || (tag == 2 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])) {
        [self dismissViewControllerAnimated:NO completion:^(void) {
            SLComposeViewController *twCtrl = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];

            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
                [twCtrl dismissViewControllerAnimated:YES completion:nil];

                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                    default:{
                        self.modalPresentationStyle = UIModalPresentationCurrentContext;
                        [self presentViewController:enterInfo1 animated:NO completion:nil];
                    }
                        break;
                    case SLComposeViewControllerResultDone: {
                        self.modalPresentationStyle = UIModalPresentationCurrentContext;
                        [self presentViewController:enterInfo1 animated:NO completion:nil];
                    }
                        break;
                }};
            
            NSString *fullString = [[formatter stringFromNumber:[NSNumber numberWithDouble:seconds]]
                                    stringByAppendingString:@" seconds of my life are estimated to be remaining by the iOS Every Moment app."];

            [twCtrl addImage:[UIImage imageNamed:@"FB-72.jpg"]];
            [twCtrl setInitialText:fullString];
            [twCtrl addURL:[NSURL URLWithString:@"http://myappurl.com"]];
            [twCtrl setCompletionHandler:completionHandler];
            [self presentViewController:twCtrl animated:YES completion:nil];
        }];
    }
}

- (IBAction)toggleComponents:(id)sender {
    if (_currentAgeLabel.hidden && _ageLabel.hidden) {
        [self showComponents];
    }
    else {
        [self handlePortrait];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;

    if (interfaceOrientation == 1) {
        [self handlePortrait];
    }
    else if (interfaceOrientation == 3 || interfaceOrientation == 4) { // Adjust label locations in landscape right or left orientation
        [self handleLandscape];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self dismissViewControllerAnimated:NO completion:^(void) {
        [self handleLandscape];
    }];
}

- (void)handlePortrait {
    backgroundView.hidden = NO;
    currAgeTxtLbl.hidden = YES;
    estTxtLbl.hidden = YES;
    _percentLabel.hidden = YES;
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;
    _progressView.hidden = YES;
    _tweetBtn.hidden = YES;
    _facebookBtn.hidden = YES;
    _configBtn.hidden = YES;
    _helpBtn.hidden = YES;
    
    _countdownLabel.frame = CGRectMake(11,20,298,85);
    secdsLifeRemLabel.frame = CGRectMake(56,85,208,21);
}

- (void)handleLandscape {
    backgroundView.hidden = YES;
    
    // Set gradient background
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient2];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _currentAgeLabel.hidden = YES;
    _ageLabel.hidden = YES;
    estTxtLbl.hidden = YES;
    currAgeTxtLbl.hidden = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    if (screenRect.size.height == 568) {
        _countdownLabel.frame = CGRectMake(140,70,298,85);
        secdsLifeRemLabel.frame = CGRectMake(185,135,208,21);
        _progressView.frame = CGRectMake(92,175,400,25);
        _percentLabel.frame = CGRectMake(82,200,400,25);
    }
    else {
        _countdownLabel.frame = CGRectMake(85,60,298,85);
        secdsLifeRemLabel.frame = CGRectMake(130,125,208,21);
        _progressView.frame = CGRectMake(40,165,400,25);
        _percentLabel.frame = CGRectMake(40,190,400,25);
    }
    
    // Handle use-case of exceeding life expectancy
    if (!exceedExp) {
        _progressView.hidden = NO;
        _percentLabel.hidden = NO;
        
        // Apply color to progress bar based on lifespan
        if (progAmount >= .66) {
            _progressView.progressTintColor = [UIColor greenColor];
        }
        else if (progAmount && progAmount > .33) {
            _progressView.progressTintColor = [UIColor yellowColor];
        }
        else {
            _progressView.progressTintColor = [UIColor redColor];
        }
    }
}

- (void)showComponents {
    currAgeTxtLbl.hidden = NO;
    estTxtLbl.hidden = NO;
    _currentAgeLabel.hidden = NO;
    _ageLabel.hidden = NO;
    _tweetBtn.hidden = NO;
    _facebookBtn.hidden = NO;
    _configBtn.hidden = NO;
    _helpBtn.hidden = NO;
    
    
    //NSLog(exceedExp ? @"Yes" : @"No");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    secdsLifeRemLabel = nil;
    shadeView = nil;
    toolbar = nil;
    self.progressView = nil;
    self.percentLabel = nil;
    self.countdownLabel = nil;
    self.ageLabel = nil;
    self.currentAgeLabel = nil;
}
/* END  UI METHODS */

@end