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
#import "ConfigViewController.h"
#import "DateCalculationUtil.h"
#import "FileHandler.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation ViewController

NSNumberFormatter *formatter;
UIToolbar *toolbar; // Used for first app run only
NSDictionary *nsdict;
double totalSecondsDub, progAmount, percentRemaining;
int slideDistance2 = 0;
bool exceedExp = NO, firstTime2 = false;
ConfigViewController *enterInfo1;
DateCalculationUtil *dateUtil;
FileHandler *fileHand;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    fileHand   = [[FileHandler alloc] init];
    dateUtil   = [[DateCalculationUtil alloc] init];
    _touchView = [_touchView init];

    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    backgroundView.frame = self.view.bounds;
    [[self view] addSubview:backgroundView];
    [[self view] sendSubviewToBack:backgroundView];

    [self setupHelpView];

    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGeneratesDecimalNumbers:NO];
    [formatter setMaximumFractionDigits:0];

    [self setupParticleView];

    tapShowPercent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleView)];
    tapShowPercent.numberOfTapsRequired = 1;
    tapShowPercent.numberOfTouchesRequired = 1;

    [_touchView addGestureRecognizer:tapShowPercent];
}

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
        [self presentViewController:enterInfo1 animated:NO completion:nil];
    }

    // Hide config view, move into place off-screen, then display
    if (nsdict != nil) {
        enterInfo1.view.hidden = YES;
        enterInfo1.view.frame = CGRectMake(750,0,enterInfo1.view.frame.size.width,enterInfo1.view.frame.size.height);
        enterInfo1.view.hidden = NO;
    }
    else {
        enterInfo1.view.frame = CGRectMake(0,0,enterInfo1.view.frame.size.width,enterInfo1.view.frame.size.height);
        enterInfo1.view.hidden = NO;
    }
}

- (void)setBackgroundImage {
    if (percentRemaining > 66.666) {
        backgroundView.image = [UIImage imageNamed:@"hglass-low.png"];
        _skView.frame = CGRectMake(210, 237, 42, 300);
    }
    else if (percentRemaining > 33.333 && percentRemaining <= 66.666) {
        backgroundView.image = [UIImage imageNamed:@"hglass-medium.png"];
        _skView.frame = CGRectMake(210, 237, 42, 265);
    }
    else {
        backgroundView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
        _skView.frame = CGRectMake(210, 237, 42, 233);
    }
}

// Toggles life view between percentage and seconds countdown
- (void)toggleView {
    if (_percentLabel.alpha == 0) {
        [UIView animateWithDuration:0.5f animations:^{
            _countdownLabel.alpha = 0;
            _percentLabel.alpha = 1;
            secdsLifeRemLabel.text = @"percent of your life remaining";
        }];
    }
    else if (_percentLabel.alpha == 1) {
        [UIView animateWithDuration:0.5f animations:^{
            _percentLabel.alpha = 0;
            _countdownLabel.alpha = 1;
            secdsLifeRemLabel.text = @"seconds of your life remaining";
        }];
    }
}

// Animates sliding out of buttons, and then back in
- (IBAction)slideBtns:(id)sender {
    if (_helpBtn.alpha == 0.0) {
        [UIView animateWithDuration:0.3f animations:^{
            _persBtn.alpha     = 1.0;
            _facebookBtn.alpha = 1.0;
            _tweetBtn.alpha    = 1.0;
            _helpBtn.alpha     = 1.0;

            _persBtn.frame     = CGRectOffset(_persBtn.frame,     55, 0);
            _facebookBtn.frame = CGRectOffset(_facebookBtn.frame, 123, 0);
            _tweetBtn.frame    = CGRectOffset(_tweetBtn.frame,    190, 0);
            _helpBtn.frame     = CGRectOffset(_helpBtn.frame,     250, 0);
        }];
    }
    else {
        [UIView animateWithDuration:0.3f animations:^{
            _persBtn.alpha     = 0.0;
            _facebookBtn.alpha = 0.0;
            _tweetBtn.alpha    = 0.0;
            _helpBtn.alpha     = 0.0;

            _persBtn.frame     = CGRectOffset(_persBtn.frame,     -55, 0);
            _facebookBtn.frame = CGRectOffset(_facebookBtn.frame, -123, 0);
            _tweetBtn.frame    = CGRectOffset(_tweetBtn.frame,    -190, 0);
            _helpBtn.frame     = CGRectOffset(_helpBtn.frame,     -250, 0);
        }];
    }
}

- (void)setupParticleView {
    // Configure the SKView
    _skView = [[SKView alloc] init];

    // Diagnostics if needed
    // _skView.showsFPS = YES; _skView.showsNodeCount = YES; _skView.alpha = 1.0;
    _skView.frame = CGRectMake(210, 237, 42, 233);
    [self.view insertSubview:_skView aboveSubview:backgroundView];

    // Create and configure scene
    _scene = [MyScene sceneWithSize:_skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeResizeFill;
    //_scene.backgroundColor = [UIColor blueColor]; // Makes actual view visible

    [_skView presentScene:_scene];
}

- (void)loadUserData {
    // Get dictionary of user data from our file handler. If dictionary is nil, request config data from user
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

/****  BEGIN USER INFORMATION METHODS  ****/
- (IBAction)setUserInfo:(id)sender {
    [enterInfo1 animateConfig:nil];
}

#pragma mark displayUserInfo Delegate function
- (void)displayUserInfo:(NSDictionary*)infoDictionary {
    // Perform setup prior to setting label values...
    NSDateComponents *currentAgeDateComp;

    if (infoDictionary != nil) {
        // Undo first time usage setup
        _countdownLabel.hidden = NO;
        secdsLifeRemLabel.hidden = NO;

        [dateUtil beginAgeProcess:infoDictionary];

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
            estTxtLbl.hidden = YES;
            secdsLifeRemLabel.text = @"seconds you've outlived estimates";
        }

        if (!_timerStarted) {
            [self updateTimerAndBar];
            [self startSecondTimer];
        }

        percentRemaining = (seconds / totalSecondsDub) * 100;
        [self setBackgroundImage];
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

    percentRemaining = (seconds / totalSecondsDub) * 100;
    
    if (percentRemaining < 0)   { percentRemaining = 0; }
    if (percentRemaining > 100) { percentRemaining = 100; }

    _percentLabel.text = [NSString stringWithFormat:@"%.8f%%", percentRemaining];
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
        visibleRect.origin      = self.view.frame.origin; // Set origin to our UIScrollView's view window
        visibleRect.size        = self.view.bounds.size;
        visibleRect.origin.x    += 25.0;
        visibleRect.origin.y    += 150.0;
        visibleRect.size.width  *= .85;
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
    NSString *serviceType;

    if ((tag == 1 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) || (tag == 2 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])) {

        if (tag == 1) {
            serviceType = SLServiceTypeTwitter;
        }
        else {
            serviceType = SLServiceTypeFacebook;
        }

        [self dismissViewControllerAnimated:NO completion:^(void) {
            SLComposeViewController *twCtrl = [SLComposeViewController composeViewControllerForServiceType:serviceType];

            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
                [twCtrl dismissViewControllerAnimated:YES completion:nil];

                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                    default:{
                       // self.modalPresentationStyle = UIModalPresentationCurrentContext;
                        [self presentViewController:enterInfo1 animated:NO completion:nil];
                        // Hide config view, move into place off-screen, then display
                        enterInfo1.view.hidden = YES;
                        enterInfo1.view.frame = CGRectMake(750,0,enterInfo1.view.frame.size.width,enterInfo1.view.frame.size.height);
                        enterInfo1.view.hidden = NO;
                    }
                        break;
                    case SLComposeViewControllerResultDone: {
                       // self.modalPresentationStyle = UIModalPresentationCurrentContext;
                        [self presentViewController:enterInfo1 animated:NO completion:nil];
                        // Hide config view, move into place off-screen, then display
                        enterInfo1.view.hidden = YES;
                        enterInfo1.view.frame = CGRectMake(750,0,enterInfo1.view.frame.size.width,enterInfo1.view.frame.size.height);
                        enterInfo1.view.hidden = NO;
                    }
                        break;
                }};

            NSString *string2 = [[formatter stringFromNumber:[NSNumber numberWithDouble:seconds]]
                                    stringByAppendingString:@" seconds of life expectancy remaining. How about you?"];

            NSString *fullString = [@"The iOS Every Moment app estimates I have " stringByAppendingString:string2];

            [twCtrl setInitialText:fullString];
            [twCtrl addURL:[NSURL URLWithString:@"http://myappurl.com"]];
            [twCtrl setCompletionHandler:completionHandler];
            [self presentViewController:twCtrl animated:YES completion:nil];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    secdsLifeRemLabel    = nil;
    toolbar              = nil;
    self.percentLabel    = nil;
    self.countdownLabel  = nil;
    self.ageLabel        = nil;
    self.currentAgeLabel = nil;
}
/* END  UI METHODS */

@end