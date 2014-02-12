/*
 Copyright (c) 2013, Nathan Wisman. All rights reserved.
 HelpView.m
 
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

#import "HelpView.h"

@implementation HelpView
NSString *countryNameStr;

- (id)initWithFrame:(CGRect)frame btnInt:(int)buttonInt ctryString:(NSString*)cString {
    self = [super initWithFrame:frame];
    NSString *helpMsg;

    if (self) {
        if (cString)
            countryNameStr = cString;

        UITapGestureRecognizer *tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelp:)];
        tapGestureRec.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRec];
        [self setUserInteractionEnabled:YES];

        UILabel *helpTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        helpMsg = [self getText:buttonInt];

        // Heiti SC Light 17.0
        [helpTextLbl setNumberOfLines:0]; // To allow line breaks in label
        [helpTextLbl setTextColor:[UIColor blackColor]];
        [helpTextLbl setBackgroundColor:[UIColor clearColor]];
        [helpTextLbl setFont:[UIFont fontWithName: @"Heiti SC Light" size: 17.0f]];
        [helpTextLbl setText:helpMsg];
        [helpTextLbl sizeToFit];
        [self addSubview:helpTextLbl];
    }

    return self;
}

- (NSString*)getText:(NSInteger)keyInt {
    NSString *helpTxt = @"";

    switch (keyInt) {
        case 1:
            helpTxt = @"Country of residence is a strong\nindicator of life expectancy.\n\n";
            helpTxt = [helpTxt stringByAppendingString:countryNameStr];
            break;

        case 2:
            helpTxt = @"Gender help";
            break;

        case 3:
            helpTxt = @"Smoker help";
            break;

        case 4:
            helpTxt = @"Hours exercise help";
            break;

        default:
            helpTxt = @"DISCLAIMER:\n\nAll life expectancy results are \nunscientific estimates. This\napplication is for entertainment\npurposes only.\n\nAll data provided is kept private\nand never shared or used\noutside of the application. \n\nLifeIsShortSoftware.com";
            break;
    }

    return helpTxt;
}

- (IBAction)hideHelp:(id)sender {
    self.hidden = YES;
}

@end
