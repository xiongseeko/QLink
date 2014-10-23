//
//  ProgressView.h
//  QLink
//
//  Created by 尤日华 on 14-10-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property(nonatomic,strong) IBOutlet UIProgressView *pvControl;

-(void)setProgressValue:(float)value;

@end
