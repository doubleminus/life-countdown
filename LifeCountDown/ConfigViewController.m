//
//  ConfigViewController.m
//  LifeCountDown
//
//  Created by doubleminus on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "DateCalculationUtil.h"

@implementation ConfigViewController
NSDictionary *personInfo;
NSString *gender;
NSDate *birthDate;

@synthesize delegate = _delegate;
@synthesize cancelButton = _cancelButton;
@synthesize genderToggle = _genderToggle;
@synthesize dobPicker = _dobPicker;
@synthesize isMale = _isMale;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!ageIsSet) {
        _cancelButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setDobPicker:nil];
    [self setCancelButton:nil];
    [self setGenderToggle:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"isMale? %d", _isMale);

    if (_isMale)
        [self.genderToggle setSelectedSegmentIndex:0];
    else
        [self.genderToggle setSelectedSegmentIndex:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Set default date in UIDatePicker
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"yyyyMMdd"];

    NSDate *defaultPickDate = [myFormatter dateFromString:@"19700101"];
    [_dobPicker setDate:defaultPickDate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(id)sender {
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];

    if ([self.genderToggle selectedSegmentIndex] == 0) {
        gender = @"m";
        _isMale = YES;
    }
    else {
        gender = @"f";
        _isMale = NO;
    }

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                                            forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    }

    [self dismissModalViewControllerAnimated:YES];
}


/*****  BEGIN BUTTON METHODS  *****/
- (IBAction)cancelPressed {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePressed {
    [self updateAge:nil];

    // Check to see if anyone is listening...
    if([_delegate respondsToSelector:@selector(displayUserInfo:)]) {
        // ...then send the delegate function with the amount entered by the user
        [_delegate displayUserInfo:personInfo];
    }

    ageIsSet = YES;
    [self dismissModalViewControllerAnimated:YES];
}
/*****  END BUTTON METHODS  *****/

@end