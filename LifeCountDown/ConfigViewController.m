/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
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
#import "BackgroundLayer.h"
#import "FileHandler.h"
#import "PWProgressView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConfigViewController
FileHandler *fileHand;
DateCalculationUtil *dateUtil;
NSDictionary *personInfo, *countryInfo, *nsDict;
NSString *country, *gender, *smokeStatus;
CGRect padScrollRect, phoneScrollRect;
UIToolbar* bgToolbar;
NSDate *birthDate;
NSArray *ageArray;
int slideDistance = 300;
double progAmount, percentRemaining;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Get dictionary of user data from our file handler. If dictionary is nil, we will request config data from user
    fileHand = [[FileHandler alloc] init];
    nsDict = [fileHand readPlist];

    [self setupScrollView];
    [self setupHelpView];
    [self generateLineViews];

    country = [countryArray objectAtIndex:[_ctryPicker selectedRowInComponent:0]]; // Set country picker values
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.ctryPicker selectRow:184 inComponent:0 animated:YES];

    _dobPicker.maximumDate = [NSDate date]; // Set our date picker's max date to today

    if (nsDict) {
        [self setupDisplay:nsDict];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (!nsDict) {
            padScrollRect = CGRectMake(450, 0, scroller.frame.size.width, scroller.frame.size.height);
        }
        else {
            padScrollRect = CGRectMake(750, 0, scroller.frame.size.width, scroller.frame.size.height);
        }

        scroller.frame = padScrollRect;
        scroller.alpha = 1.0;
    }

    // Setup our circular progress view in bottom left corner
    self.progressView = [[PWProgressView alloc] init];
    self.progressView.layer.cornerRadius = 5.0f;
    self.progressView.clipsToBounds = YES;
    self.progressView.frame = CGRectMake(10.0, 510.0, 50.0, 50.0);
    [scroller insertSubview:self.progressView aboveSubview:bgToolbar];
    self.progressView.alpha = 1.0;

    [self updateProgPercentage:nil];
}

-(IBAction)updateProgPercentage:(id)sender {
    // Set percentage of life in progress view
    [self writeDictionary];

    if (personInfo != nil) {
        DateCalculationUtil *dUtil = [[DateCalculationUtil alloc] initWithDict:personInfo];
        progAmount = [dUtil secondsRemaining] / [dUtil totalSecondsInLife];
        percentRemaining = progAmount * 100.0;

        // Handle outliving life expectancy
        if (percentRemaining < 0) {
            percentRemaining = 0;
        }

        [self.progressView setProgress:progAmount];
        _progressView.percentLabel.text = [NSString stringWithFormat:@"%.1f%%", percentRemaining];
    }
}

// Move our PWProgressView as the user scrolls
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_progressView setFrame:CGRectMake(10.0, (scroller.contentOffset.y + scroller.frame.size.height)-58, 50.0, 50.0)];
}

- (void)setupScrollView {
    // Set up scroll view
    [self.view addSubview:self->contentView];
    ((UIScrollView *)self.view).contentSize = self->contentView.frame.size;
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320,968)];

    // Create border around our config view content
    [contentView.layer setCornerRadius:15.0f];
    [contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [contentView.layer setBorderWidth:1.5f];

    // Adjust for iPad UI differences
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [scroller setAlpha:0.0]; // Make scrollview invisible so we can move it and display it stealthily
        [aboutBtn setFrame:CGRectMake(125, 954, 55, 26)];
        [scroller setScrollEnabled:NO];
        [scroller setContentSize:CGSizeMake(320,2000)];

        CALayer *viewLayer = [scroller layer]; // Round uiview's corners a bit
        [viewLayer setMasksToBounds:YES];
        [viewLayer setCornerRadius:5.0f];

        [saveBtn setHidden:YES];
        [aboutBtn setHidden:NO];
    }

    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    [bgLayer setFrame:contentView.bounds];
    [self.view.layer insertSublayer:bgLayer atIndex:0];

    // Get array of countries from Countries.plist via calculation util to populate UIPickerView values
    dateUtil = [[DateCalculationUtil alloc] initWithDict:nsDict];
    countryInfo = [dateUtil getCountryDict];
    countryArray = [countryInfo allKeys];
    countryArray = [countryArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)setupHelpView {
    // Setup help view but hide it
    _hView = [[HelpView alloc] init];
    [self.view addSubview:_hView];

    bgToolbar = [[UIToolbar alloc] initWithFrame:contentView.frame];
    bgToolbar.barStyle = UIBarStyleDefault;
    bgToolbar.alpha = .9;
    [self.view insertSubview:bgToolbar belowSubview:_hView];
    bgToolbar.hidden = YES;

    // Create tap gesture for dismissing Help View
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHelp:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    [_hView addGestureRecognizer:tap1];
}

- (IBAction)showHelp:(id)sender {
    UIButton *btn;
    CGRect visibleRect;
    country = @"";

    if (!_hView || _hView.hidden == YES) {
        visibleRect.origin = scroller.contentOffset; // Set origin to our uiscrollview's view window
        visibleRect.size = scroller.bounds.size;
        visibleRect.origin.x += 25.0;
        visibleRect.origin.y += 150.0;

        // Now modify to squash the HelpView into the size we want
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            visibleRect.size.width *= .36;
            visibleRect.size.height *= .25;

            if ([sender isKindOfClass:[UIButton class]]) {
                btn = (UIButton *)sender;

                if ([sender tag] != 0) { // If it's not our "About" button, change location
                    visibleRect.origin.y = btn.frame.origin.y - 115;
                }
            }
        }
        else {
            visibleRect.size.width *= .85;
            visibleRect.size.height *= .5;
        }

        [_hView setFrame:visibleRect];

        country = [countryArray objectAtIndex:[_ctryPicker selectedRowInComponent:0]];
        ageArray = [countryInfo objectForKey:country];

        // Build string of Country name information
        if ([sender tag] && [sender tag] == 1 && ageArray && [ageArray count] == 2) {
            country = [self buildCountryString:country];
        }

        [_hView setText:country btnInt:(int)[sender tag]];
        [_hView setHidden:NO];
        [bgToolbar setHidden:NO];
    }
    else {
        [_hView setHidden:YES];
        [bgToolbar setHidden:YES];
    }
}

- (void)generateLineViews {
    NSMutableArray *lineArray = [[NSMutableArray alloc] init];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 340, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 575, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 640, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 700, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 790, self.view.frame.size.width, 1)]];
    [lineArray addObject:[[UIView alloc] initWithFrame:CGRectMake(0, 890, self.view.frame.size.width, 1)]];

    for (UIView *u in lineArray) {
        u.backgroundColor = [UIColor whiteColor];
        [self.view insertSubview:u belowSubview:bgToolbar];
    }
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

// Method to allow sliding view out from side on iPad
- (IBAction)animateConfig:(id)sender {
    nsDict = [fileHand readPlist];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && nsDict) {
        if (scroller.frame.origin.x == 750) { // SLIDE CONFIG VIEW OUT
            [UIView animateWithDuration:0.5f animations:^{
                scroller.frame = CGRectOffset(scroller.frame, slideDistance * -1, 0);
            }];
        }
        else if (scroller.frame.origin.x == 450) { // SLIDE CONFIG VIEW BACK IN
            if (_genderToggle.selectedSegmentIndex != UISegmentedControlNoSegment) { // Force user to supply gender field value
                [self updateAge:nil];
                bgToolbar.hidden = YES;

                [UIView animateWithDuration:0.5f animations:^{
                    scroller.frame = CGRectOffset(scroller.frame, slideDistance, 0);
                }];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing gender"
                                                                message:@"Please select a gender to continue."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

// Disable landscape orientation
- (BOOL)shouldAutorotate {
    return NO;
}

-(void)writeDictionary {
    NSNumber *countryIndex = [NSNumber numberWithInteger:[_ctryPicker selectedRowInComponent:0]];
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];
    country = [countryArray objectAtIndex:[_ctryPicker selectedRowInComponent:0]];
    //NSLog(@"COUNTRY: %@", country);

    if ([self.genderToggle selectedSegmentIndex] == 0) {
        gender = @"f";
    }
    else {
        gender = @"m";
    }

    if (!self.smokeSwitch.isOn) {
        smokeStatus = @"nonsmoker";
    }
    else {
        smokeStatus = @"smoker";
    }

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects:
                      [NSArray arrayWithObjects: country, countryIndex, birthDate,
                       gender, smokeStatus, _daysLbl.text, nil]
                                                 forKeys: [NSArray arrayWithObjects: @"country", @"countryIndex", @"birthDate",
                                                           @"gender", @"smokeStatus", @"hrsExercise", nil]];
    }
}

// Determines all age information, via the user-provided birthdate
- (IBAction)updateAge:(id)sender {
    [self writeDictionary];

    if (personInfo != nil) {
        [fileHand writePlist:personInfo];

        // Check to see if anyone is listening...
        if ([_delegate respondsToSelector:@selector(displayUserInfo:)]) {
            // ...then send the delegate function with amount entered by the user
            [_delegate displayUserInfo:personInfo];

            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                if (!nsDict) {
                    [self animateConfig:nil];
                }
            }
        }
    }
}

- (IBAction)sliderChanged:(id)sender {
    NSInteger val = 0;
    // Cast sender to UISlider so we can get tag #
    int tagNum = (int)[(UIButton *)sender tag];

    if (tagNum == 1) {
        _daySlider = (UISlider*)sender;
        val = lround(_daySlider.value);
        _daysLbl.text = [NSString stringWithFormat:@"%ld", (long)val];

        plusLbl.hidden = (val < 10) ? YES : NO;
    }
    else if (tagNum == 2) {
        _sitSlider = (UISlider*)sender;
        val = lround(_sitSlider.value);
        _sitLabel.text = [NSString stringWithFormat:@"%ld", (long)val];

        plusLbl2.hidden = (val < 10) ? YES : NO;
    }
}

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
            // Set Gender switch in UI
            if ([[infoDctnry objectForKey:@"gender"]isEqualToString:@"f"]) {
                [_genderToggle setSelectedSegmentIndex:0];
            }
            else {
                [_genderToggle setSelectedSegmentIndex:1];
            }

            // Set country in UIPicker
            [self.ctryPicker selectRow:[[infoDctnry objectForKey:@"countryIndex"] integerValue] inComponent:0 animated:NO];

            // Set smoker switch in UI
            if ([[infoDctnry objectForKey:@"smokeStatus"]isEqualToString:@"nonsmoker"]) {
                [_smokeSwitch setOn:NO];
            }
            else {
                [_smokeSwitch setOn:YES];
            }

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
    if (fVal <= 10)
        plusLbl.hidden = YES;
    else
        plusLbl.hidden = NO;
}

// Builds a string combining Country name, male & female life expectancies, to display in helpview
- (NSString *)buildCountryString:(NSString*)cString {
    NSString *lineStr = @"", *tempCString = @"";
    
    // Build ---- string to underline our country name within label
    if (cString &&  cString.length > 0) {
        tempCString = cString;
        
        for (int i=0; i<((country.length)/2)+2; i++) {
            lineStr = [lineStr stringByAppendingString:@"--"];
        }
        
        // Now add rest of string to show each life expectancy age for each gender in given country
        cString = [countryArray objectAtIndex:[_ctryPicker selectedRowInComponent:0]];
        cString = [cString stringByAppendingString:@"\n"];
        cString = [cString stringByAppendingString:lineStr];
        cString = [cString stringByAppendingString:@"\nMale: "];
        cString = [cString stringByAppendingString:[ageArray[0] stringValue]];
        cString = [cString stringByAppendingString:@"\nFemale: "];
        cString = [cString stringByAppendingString:[ageArray[1] stringValue]];
    }
    
    return cString;
}

- (void)viewDidUnload {
    scroller = nil;
    contentView = nil;
    plusLbl = nil;
    _dobPicker = nil;
    _genderToggle = nil;
    _daysLbl = nil;
    _smokeSwitch = nil;
    bgToolbar = nil;
    
    [super viewDidUnload];
}

/* // Make UIPickerView font white - cannot use until we can easily make UIDatePicker font white also
 - (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
 NSString *title = countryArray[row];
 NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
 
 return attString;
 
 } */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateProgPercentage:_ctryPicker.self];
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