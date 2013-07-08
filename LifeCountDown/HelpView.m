//
//  HelpView.m
//  LifeCountDown
//
//  Created by doubleminus on 6/26/13.
//
//

#import "HelpView.h"

@implementation HelpView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UITapGestureRecognizer *tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelp:)];
        tapGestureRec.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRec];
        self.userInteractionEnabled = YES;

        UILabel *helpTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        NSString *helpMsg = @"PUBLIC DISCLAIMER:\n\nAll life expectancy results are \nunscientific estimates. This\napplication is for entertainment\npurposes only.\n\nAll data provided is kept private\nand never shared or examined\noutside of the application.\n\n*touch to dismiss*";

        // Heiti SC Light 17.0
        [helpTextLbl setNumberOfLines:0]; // To allow line breaks in label
        [helpTextLbl setTextColor:[UIColor whiteColor]];
        [helpTextLbl setBackgroundColor:[UIColor clearColor]];
        [helpTextLbl setFont:[UIFont fontWithName: @"Heiti SC Light" size: 17.0f]];
        [helpTextLbl setText:helpMsg];
        [helpTextLbl sizeToFit];
        [self addSubview:helpTextLbl];
    }

    return self;
}

- (IBAction)hideHelp:(id)sender {
    self.hidden = YES;
}

@end
