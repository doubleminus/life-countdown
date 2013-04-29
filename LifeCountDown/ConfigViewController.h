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
    id<ConfigViewDelegate> delegate;
}

@property (strong, nonatomic) NSDictionary* viewDict;
@property (strong, nonatomic) IBOutlet UIDatePicker *dobPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderToggle;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, assign) id delegate;

- (IBAction)cancelPressed;
- (IBAction)savePressed;
- (void)deletePlist;

@end