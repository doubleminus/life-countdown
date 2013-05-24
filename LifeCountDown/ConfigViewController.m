//
//  ConfigViewController.m
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "DateCalculationUtil.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConfigViewController
NSDictionary *personInfo;
NSString *gender, *smokeStatus;
NSDate *birthDate;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self->contentView];
    ((UIScrollView *)self.view).contentSize = self->contentView.frame.size;

    contentView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"blk_tile-drk.png"]];

    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320,700)];
    [scroller setContentOffset:CGPointMake(0,0) animated:NO];

    scroller.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    NSArray *buttons = [NSArray arrayWithObjects: cancelBtn, saveBtn, nil];

    for (UIButton *btn in buttons) {
        // Set the button Text Color
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];

        // Draw a custom gradient
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.frame = btn.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                              (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                              nil];
        [btn.layer insertSublayer:btnGradient atIndex:0];

        // Round button corners
        CALayer *btnLayer = [btn layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    scroller = nil;
    saveBtn = nil;
    cancelBtn = nil;
    cancelBtn = nil;
    contentView = nil;
    [self setDobPicker:nil];
    [self setGenderToggle:nil];
    [self setDaySlider:nil];
    [self setDaysLbl:nil];
    [self setSmokeToggle:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //[self deletePlist];
    cancelBtn.hidden = YES;
    _dobPicker.maximumDate = [NSDate date]; // Set our date picker's max date to today
    [self readPlist];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
    return NO;
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(id)sender {
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];

    if ([self.genderToggle selectedSegmentIndex] == 0)
        gender = @"f";
    else
        gender = @"m";
    
    if ([self.smokeToggle selectedSegmentIndex] == 0)
        smokeStatus = @"nonsmoker";
    else
        smokeStatus = @"smoker";
    

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, smokeStatus, nil]
                                                                            forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", @"smokeStatus", nil]];
        if (personInfo != nil)
            [self writePlist:personInfo];
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sliderChanged:(id)sender {
    _daySlider = (UISlider *)sender;
    NSInteger val = lround(_daySlider.value);
    _daysLbl.text = [NSString stringWithFormat:@"%d",val];
}

/**** BEGIN PLIST METHODS ****/
- (void)readPlist {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // Get path to documents directory from the list.
    path = [rootPath stringByAppendingPathComponent:@"Data.plist"]; // Create a full file path.

    if (path != nil && path.length > 1 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
        _viewDict = (NSDictionary *)[NSPropertyListSerialization
                                     propertyListFromData:plistXML
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                     format:&format
                                     errorDescription:&errorDesc];
        if (!_viewDict) {
            //NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        else {
            // If we have ALL of the values we need, display info to user.
            if ([_viewDict objectForKey:@"infoDict"] != nil) {
                NSDictionary *nsDict = [_viewDict objectForKey:@"infoDict"];

                if (nsDict != nil) {
                    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
                    [myFormatter setDateFormat:@"yyyyMMdd"];

                    // Birthdate has already been set, so set our datepicker
                    if ([nsDict objectForKey:@"birthDate"] != nil) {
                        //NSLog(@"birthday key: %@", [nsDict objectForKey:@"birthDate"]);
                        NSString *bdayStr = [myFormatter stringFromDate:[nsDict objectForKey:@"birthDate"]];
                        [_dobPicker setDate:[myFormatter dateFromString:bdayStr]];

                        if ([nsDict objectForKey:@"gender"] != nil) {
                            cancelBtn.hidden = NO;

                            if ([[nsDict objectForKey:@"gender"]isEqualToString:@"f"])
                                [_genderToggle setSelectedSegmentIndex:0];
                            else
                                [_genderToggle setSelectedSegmentIndex:1];
                            
                            if ([[nsDict objectForKey:@"smokeStatus"]isEqualToString:@"nonsmoker"])
                                [_smokeToggle setSelectedSegmentIndex:0];
                            else
                                [_smokeToggle setSelectedSegmentIndex:1];
                        }
                    }
                    // Otherwise, fall back on default date of January 1, 1970
                    else {
                        NSDate *defaultPickDate = [myFormatter dateFromString:@"19700101"];
                        [_dobPicker setDate:defaultPickDate];
                    }
                }
            }
        }
    }
}

- (void)writePlist:(NSDictionary*)infoDict {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];

    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: infoDict, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"infoDict", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];

    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        //NSLog(@"file written to path: %@", path);
    }
    /*else {
     NSLog(@"Error in writing to file: %@", error);
     }*/
}

- (void)deletePlist {
    // For error information
    NSError *error;

    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"Data.plist"];

    // Attempt to delete the file at filePath2
    if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);

    // Show contents of Documents directory for debugging
    // NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}
/**** END PLIST METHODS ****/


/*****  BEGIN BUTTON METHODS  *****/
- (IBAction)cancelPressed {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePressed {
    [self updateAge:nil];

    // Check to see if anyone is listening...
    if([_delegate respondsToSelector:@selector(displayUserInfo:)]) {
        // ...then send the delegate function with amount entered by the user
        [_delegate displayUserInfo:personInfo];
    }
}
/*****  END BUTTON METHODS  *****/

@end