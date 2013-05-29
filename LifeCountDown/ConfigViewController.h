//
//  ConfigViewController.h
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//delegate to return amount entered by the user
@protocol ConfigViewDelegate <NSObject>

@optional
- (void)displayUserInfo:(NSDictionary*)personInfo;
@end

@interface ConfigViewController : UIViewController {
    NSString *path;
    IBOutlet UITextField *amountTextField;
    IBOutlet UIView *contentView;
    __weak IBOutlet UIScrollView *scroller;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *saveBtn;
    __weak IBOutlet UILabel *plusLbl;
}

@property (strong, nonatomic) NSDictionary* viewDict;
@property (strong, nonatomic) IBOutlet UIDatePicker *dobPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderToggle;
@property (nonatomic, assign) id delegate;
@property (weak, nonatomic) IBOutlet UISlider *daySlider;
@property (weak, nonatomic) IBOutlet UILabel *daysLbl;
@property (strong, nonatomic) IBOutlet UISwitch *smokeSwitch;
@property (strong, nonatomic) UIColor *thumbTintColor;
@property (strong, nonatomic) UIColor *onTintColor;

- (IBAction)cancelPressed;
- (IBAction)savePressed;
- (void)deletePlist;

@end