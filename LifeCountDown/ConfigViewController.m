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

    //[self deletePlist];
    _cancelButton.hidden = YES;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Determines all age information, via the user-provided birthdate
- (void)updateAge:(id)sender {
    // Obtain an NSDate object built from UIPickerView selections
    birthDate = [_dobPicker date];

    if ([self.genderToggle selectedSegmentIndex] == 0)
        gender = @"m";
    else
        gender = @"f";

    if (birthDate != nil && gender != nil) {
        personInfo = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: birthDate, gender, nil]
                                                                            forKeys: [NSArray arrayWithObjects: @"birthDate", @"gender", nil]];
        if (personInfo != nil)
            [self writePlist:personInfo];
    }

    [self dismissModalViewControllerAnimated:YES];
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
                            _cancelButton.hidden = NO;

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
    if ([fileMgr removeItemAtPath:filePath2 error:&error] != YES) {
        //NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }

    // Show contents of Documents directory for debugging purposes
    //NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
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
        // ...then send the delegate function with the amount entered by the user
        [_delegate displayUserInfo:personInfo];
    }

    [self dismissModalViewControllerAnimated:YES];
}
/*****  END BUTTON METHODS  *****/

@end