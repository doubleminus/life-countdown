/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 ViewController.h
 
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

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ConfigViewController.h"
#import <SpriteKit/SpriteKit.h>

@class YLProgressBar;

@interface ViewController : UIViewController <ConfigViewDelegate> {
    UIImageView *backgroundView;
    double seconds;
    
    IBOutlet UIImageView *bitView;
    __weak IBOutlet UILabel *secdsLifeRemLabel, *currAgeTxtLbl, *estTxtLbl;
}

@property IBOutlet SKView *skView;

@property (strong, nonatomic) IBOutlet UIButton *helpBtn, *tweetBtn, *facebookBtn, *configBtn;
@property (strong, nonatomic) IBOutlet UILabel *currentAgeLabel, *ageLabel, *countdownLabel, *percentLabel;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressView;
@property (strong, nonatomic) NSTimer *secondTimer;
@property (strong, nonatomic) IBOutlet UIView *touchView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *kTouch;
@property (strong, nonatomic) HelpView *helpView;
@property (nonatomic) bool timerStarted;

- (IBAction)toggleComponents:(id)sender;
- (IBAction)tweetTapGest:(id)sender;
- (IBAction)setUserInfo:(id)sender;
- (IBAction)showHelp:(id)sender;
- (void)loadUserData;

@end