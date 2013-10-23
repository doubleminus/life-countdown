/*
 Copyright (c) 2013, Nathan Wisman. All rights reserved.
 ConfigViewController.m
 
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

#import "ConfigViewController.h"
#import "DateCalculationUtil.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConfigViewController
NSDictionary *personInfo;
NSString *country, *gender, *smokeStatus;
NSDate *birthDate;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up scroll view
    [self.view addSubview:self->contentView];
    ((UIScrollView *)self.view).contentSize = self->contentView.frame.size;

    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320,1000)];
    [scroller setContentOffset:CGPointMake(0,0) animated:NO];

  //  UIColor *darkGray = [UIColor colorWithRed:78.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1];
  //  [scroller setBackgroundColor:darkGray];

    // Style/skin buttons
    NSArray *buttons = [NSArray arrayWithObjects: cancelBtn, saveBtn, nil];

    for (UIButton *btn in buttons) {
        // Set button text color
        [btn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateHighlighted];

        [btn setBackgroundColor:[UIColor whiteColor]];

        // Round corners
        CALayer *btnLayer = [btn layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
    }

    // Get array of countries from Countries.plist via calculation util to populate uipickerview values
    DateCalculationUtil *dateUtil = [[DateCalculationUtil alloc] init];
    countryArray = [[dateUtil getCountryDict] allKeys];
    countryArray = [countryArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    // Setup help view but hide it
    [self setupHelpView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.ctryPicker selectRow:184 inComponent:0 animated:YES];

    cancelBtn.hidden = YES;
    _dobPicker.maximumDate = [NSDate date]; // Set our date picker's max date to today
    [self readPlist];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Fade-in our view
    self.view.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{self.view.alpha = 1.f;}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Disable landscape orientation
- (BOOL)shouldAutorotate {
    return NO;
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(id)sender {
    NSNumber *countryIndex = [NSNumber numberWithInt:[_ctryPicker selectedRowInComponent:0]];
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];
    country = [countryArray objectAtIndex:[_ctryPicker selectedRowInComponent:0]];

    //NSLog(@"COUNTRY: %@", country);

    if ([self.genderToggle selectedSegmentIndex] == 0)
        gender = @"f";
    else
        gender = @"m";

    if (!self.smokeSwitch.isOn)
        smokeStatus = @"nonsmoker";
    else
        smokeStatus = @"smoker";

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects:
                      [NSArray arrayWithObjects: country, countryIndex, birthDate,
                                                 gender, smokeStatus, _daysLbl.text, nil]
                               forKeys: [NSArray arrayWithObjects: @"country", @"countryIndex", @"birthDate",
                                                                   @"gender", @"smokeStatus", @"hrsExercise", nil]];

        if (personInfo != nil)
            [self writePlist:personInfo];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sliderChanged:(id)sender {
    _daySlider = (UISlider*)sender;
    NSInteger val = lround(_daySlider.value);
    _daysLbl.text = [NSString stringWithFormat:@"%d", val];
    [self togglePlus:val];
}

/**** BEGIN PLIST METHODS ****/
- (void)readPlist {
    NSPropertyListFormat format;
    NSString *errorDesc = nil;

    // Get path to documents directory from the list.
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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

                if (nsDict != nil)
                    [self setupDisplay:nsDict];
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
/**** END PLIST METHODS ****/

// Set our UI component values based on what user entered previously
- (void)setupDisplay:(NSDictionary*)infoDctnry {
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"yyyyMMdd"];

    // Birthdate has already been set, so set our datepicker
    if ([infoDctnry objectForKey:@"birthDate"] != nil) {
        //NSLog(@"birthday key: %@", [nsDict objectForKey:@"birthDate"]);
        NSString *bdayStr = [myFormatter stringFromDate:[infoDctnry objectForKey:@"birthDate"]];
        [_dobPicker setDate:[myFormatter dateFromString:bdayStr]];

        if ([infoDctnry objectForKey:@"gender"] != nil) {
            cancelBtn.hidden = NO;

            // Set Gender switch in UI
            if ([[infoDctnry objectForKey:@"gender"]isEqualToString:@"f"])
                [_genderToggle setSelectedSegmentIndex:0];
            else
                [_genderToggle setSelectedSegmentIndex:1];

            // Set country in uipicker
            [self.ctryPicker selectRow:[[infoDctnry objectForKey:@"countryIndex"] integerValue] inComponent:0 animated:NO];

            // Set smoker switch in UI
            if ([[infoDctnry objectForKey:@"smokeStatus"]isEqualToString:@"nonsmoker"])
                [_smokeSwitch setOn:NO];
            else
                [_smokeSwitch setOn:YES];

            // Set hours of exercise/week
            [_daysLbl setText:[infoDctnry objectForKey:@"hrsExercise"]];
            [_daySlider setValue:[_daysLbl.text floatValue]];
            [self togglePlus:[_daysLbl.text floatValue]];
        }
    }
    // Otherwise, fall back on default date of January 1, 1970
    else {
        NSDate *defaultPickDate = [myFormatter dateFromString:@"19700101"];
        [_dobPicker setDate:defaultPickDate];
    }
}

- (void)togglePlus:(NSInteger)fVal {
    if (fVal <= 20)
        plusLbl.hidden = YES;
    else
        plusLbl.hidden = NO;
}

- (IBAction)showHelp:(id)sender {
    if (_hView.hidden == YES)
        _hView.hidden = NO;
    else
        _hView.hidden = YES;
}

- (void)setupHelpView {
    // Initialize view, and hide it
    _hView = [[HelpView alloc] initWithFrame:CGRectMake(30.0, 520.0, 260.0, 260.0)];
    _hView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_hView];
    _hView.alpha = 0.75;
    _hView.hidden = YES;
    _hView.layer.cornerRadius = 10.0f;

    // Set drop shadow
    [_hView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_hView.layer setShadowOpacity:0.8];
    [_hView.layer setShadowRadius:3.0];
    [_hView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

/*****  BEGIN BUTTON METHODS  *****/
- (IBAction)cancelPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewDidUnload {
    scroller = nil;
    saveBtn = nil;
    cancelBtn = nil;
    cancelBtn = nil;
    contentView = nil;
    plusLbl = nil;
    _dobPicker = nil;
    _genderToggle = nil;
    _daysLbl = nil;
    _smokeSwitch = nil;
    _thumbTintColor = nil;
    _onTintColor = nil;

    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return countryArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return countryArray[row];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {}

@end