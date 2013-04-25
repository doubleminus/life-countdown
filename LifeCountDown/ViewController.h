//
//  ViewController.h
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigViewController.h"

@interface ViewController : UIViewController <ConfigViewDelegate> {
    NSTimer *secondTimer;
    NSString *path, *bundle;
    double seconds;
    bool timerStarted;
}

@property (strong, nonatomic) IBOutlet UILabel *currentAgeLabel, *dateLabel, *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *youAreLabel, *countdownLabel;
@property (strong, nonatomic) NSDictionary* viewDict;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;

-(IBAction)setUserInfo;

@end