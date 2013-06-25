//
//  ViewController.h
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigViewController.h"

@class YLProgressBar;

@interface ViewController : UIViewController <ConfigViewDelegate> {
    NSTimer *secondTimer;
    NSString *path, *bundle;
    double seconds;
    bool timerStarted;
    __weak IBOutlet UILabel *detailsLabel;
    __weak IBOutlet UILabel *secdsLifeRemLabel;
    __weak IBOutlet UIButton *iButton;
}

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentAgeLabel, *dateLabel, *ageLabel;
@property (strong, nonatomic) NSDictionary* viewDict;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressView;

- (IBAction)toggleComponents:(id)sender;
- (IBAction)setUserInfo;
- (NSString*)getPath;
- (void)verifyPlist;

@end