//
//  PlView.h
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlView : UIView

@property(nonatomic,strong) IBOutlet OrderButton *btnLeftTop;
@property(nonatomic,strong) IBOutlet OrderButton *btnRightTop;
@property(nonatomic,strong) IBOutlet OrderButton *btnLeftMiddle;
@property(nonatomic,strong) IBOutlet OrderButton *btnMiddle;
@property(nonatomic,strong) IBOutlet OrderButton *btnRightMiddle;
@property(nonatomic,strong) IBOutlet OrderButton *btnLeftBottom;
@property(nonatomic,strong) IBOutlet OrderButton *btnRightBottom;

@end
