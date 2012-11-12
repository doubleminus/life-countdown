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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(id)sender {
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];

    if ([self.genderToggle selectedSegmentIndex] == 0) {
        gender = @"m";
    }
    else {
        gender = @"f";
    }

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                                            forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
    }

    [self dismissModalViewControllerAnimated:YES];
}

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
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
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
                            if ([[nsDict objectForKey:@"gender"]isEqualToString:@"m"])
                                [_genderToggle setSelectedSegmentIndex:0];
                            else
                                [_genderToggle setSelectedSegmentIndex:1];
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