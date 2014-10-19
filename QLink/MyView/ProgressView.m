//
//  ProgressView.m
//  QLink
//
//  Created by 尤日华 on 14-10-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setProgressValue:(float)value
{
    _pvControl.progress += value;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
