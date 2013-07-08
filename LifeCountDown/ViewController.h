//
//  ViewController.h
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigViewController.h"
#import "HelpView.h"

@class YLProgressBar;

@interface ViewController : UIViewController <ConfigViewDelegate> {
    NSTimer *secondTimer;
    NSString *path, *bundle;
    double seconds;
    bool timerStarted;

    __weak IBOutlet UILabel *helpLabel, *detailsLabel, *secdsLifeRemLabel;
    __weak IBOutlet UIButton *iButton;
}

@property (strong, nonatomic) IBOutlet UILabel *currentAgeLabel, *dateLabel, *ageLabel,
                                               *countdownLabel, *percentLabel;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressView;
@property (strong, nonatomic) HelpView *hView;
@property (strong, nonatomic) NSDictionary* viewDict;

- (IBAction)toggleComponents:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)setUserInfo;
- (NSString*)getPath;
- (void)verifyPlist;

@end