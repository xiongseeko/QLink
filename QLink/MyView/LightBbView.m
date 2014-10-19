//
//  LightBbView.m
//  QLink
//
//  Created by SANSAN on 14-9-28.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "LightBbView.h"

@implementation LightBbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)btnPressed:(OrderButton *)sender
{
    if (self.delegate) {
        [self.delegate orderDelegatePressed:sender];
    }
}

- (IBAction)btnLightPressed:(OrderButton *)sender
{
    if (self.delegate) {
        [self.delegate orderDelegatePressed:sender];
    }
}

-(IBAction)btnColorPressed:(OrderButton *)sender
{
    if (self.delegate) {
        [self.delegate orderDelegatePressed:sender];
    }
}

@end
