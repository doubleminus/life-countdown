/*
 Copyright (c) 2013-2014, Nathan Wisman. All rights reserved.
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
NSString *countryNameStr, *helpMsg;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UITapGestureRecognizer *tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelp:)];
        tapGestureRec.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRec];
        [self setUserInteractionEnabled:YES];

        _helpTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 20)];

        // Heiti SC Light 17.0
        [_helpTextLbl setNumberOfLines:0]; // To allow line breaks in label
        [_helpTextLbl setTextColor:[UIColor blackColor]];
        [_helpTextLbl setBackgroundColor:[UIColor clearColor]];
        [_helpTextLbl setFont:[UIFont fontWithName: @"Heiti SC Light" size: 17.0f]];

        [_helpTextLbl setLineBreakMode:NSLineBreakByWordWrapping];
    }

    return self;
}

- (void)setText:(NSString*)bodyTxt btnInt:(int)buttonInt {
    [_helpTextLbl setText:@""];

    if (bodyTxt) {
        countryNameStr = bodyTxt;
    }

    [_helpTextLbl setText:[self getText:buttonInt]];
    [_helpTextLbl sizeToFit];
    [self addSubview:_helpTextLbl];
}

- (NSString*)getText:(NSInteger)keyInt {
    NSString *helpTxt = @"";

    switch (keyInt) {
        case 1:
            helpTxt = @"Country of residence is a strong indicator of life expectancy.\n\n";
            helpTxt = [helpTxt stringByAppendingString:countryNameStr];
            helpTxt = [helpTxt stringByAppendingString:@"\n\nSOURCE: Life expectancy: Life expectancy by country, 2011, World Health Organization"];
            break;

        case 2:
            helpTxt = @"Gender is one of the most well-known, reliable indicators of life expectancy. Females generally live longer than males, but that varies by country.\n\nSOURCE: Life expectancy: Life expectancy by country, 2011, World Health Organization.";
            break;

        case 3:
            helpTxt = @"Smoking reduces life expectancy roughly 10 years on average.\n\nSOURCE: 21st-Century Hazards of Smoking and Benefits of Cessation in the United States, 2012, The New England Journal of Medicine.";
            break;

        case 4:
            helpTxt = @"7 minutes of life is added for every minute of exercise per week.\n\nSOURCE: Leisure Time Physical Activity of Moderate to Vigorous Intensity and Mortality: A Large Pooled Cohort Analysis, 2012, Public Library of Science.";
            break;

        default:
            helpTxt = @"DISCLAIMER: All life expectancy results are unscientific estimates. This application is for entertainment purposes only.\n\nAll data provided is kept private and never shared or used outside of the application. \n\nLifeIsShortSoftware.com";
            break;
    }

    return helpTxt;
}

- (IBAction)hideHelp:(id)sender {
    self.hidden = YES;
}

@end
