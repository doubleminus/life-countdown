/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
 ConfigViewController.h
 
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
#import "HelpView.h"

@class PWProgressView;

// Delegate to return amount entered by the user
@protocol ConfigViewDelegate <NSObject>

@optional
    - (void)displayUserInfo:(NSDictionary*)personInfo;
@end

@interface ConfigViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    UITapGestureRecognizer *tappy;
    NSString *path;
    NSArray *countryArray;
    CGRect visibleRect, backupRect;
    IBOutlet UITextField *amountTextField;
    IBOutlet UIButton *exerciseBtn, *smokeBtn, *countryBtn, *genderBtn;
    IBOutlet UIView *contentView;
    __weak IBOutlet UIScrollView *scroller;
    __weak IBOutlet UILabel *plusLbl, *plusLbl2, *helpLabel;
    __weak IBOutlet UIButton *aboutBtn, *saveBtn;
}

@property (nonatomic, strong) PWProgressView *progressView;
@property (nonatomic, assign) id delegate;
@property (weak,   nonatomic) IBOutlet UISlider *daySlider, *sitSlider;
@property (weak,   nonatomic) IBOutlet UILabel *daysLbl, *sitLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *ctryPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *dobPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderToggle;
@property (strong, nonatomic) IBOutlet UISwitch *smokeSwitch;
@property (strong, nonatomic) NSDictionary* viewDict;
@property (strong, nonatomic) HelpView *hView;

- (IBAction)showHelp:(id)sender;
- (IBAction)animateConfig:(id)sender;
- (IBAction)updateAge:(id)sender;
- (IBAction)updateProgPercentage:(id)sender;
- (NSString *)buildCountryString:(NSString*)cString;

@end