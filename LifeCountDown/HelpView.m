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
    }

    return self;
}

- (IBAction)hideHelp:(id)sender {
    self.hidden = YES;
}

@end
