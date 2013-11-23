//
//  IpadControllerViewController.h
//  Life Count
//
//  Created by doubleminus on 11/19/13.
//
//

#import <UIKit/UIKit.h>
#import "ConfigViewController.h"

@class YLProgressBar;

@interface IpadControllerViewController : UIViewController <ConfigViewDelegate> {
    UIImageView *backgroundView1;
    NSString *path1, *bundle1;
    double seconds1;

    __weak IBOutlet UIButton *setInfoButton;
    

   // __weak IBOutlet UILabel *secdsLifeRemLabel1, *currAgeTxtLbl1, *estTxtLbl1;
   // __weak IBOutlet UIButton *setInfoBtn1;
}
/*
@property (strong, nonatomic) NSDictionary *viewDict1;
@property (strong, nonatomic) NSTimer *secondTimer1;
@property (nonatomic) bool timerStarted1;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *touchToggle1;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressView1;
@property (strong, nonatomic) IBOutlet UILabel *currentAgeLabel1, *ageLabel1, *countdownLabel1, *percentLabel1;
*/
- (IBAction)toggleComponents1:(id)sender;
- (IBAction)setUserInfo1;
- (NSString*)getPath1;
- (void)verifyPlist1;

@end