//
//  BsTcView.h
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderButton.h"

@interface BsTcView : UIView

@property (nonatomic,strong) IBOutlet OrderButton *btnAd;
@property (nonatomic,strong) IBOutlet OrderButton *btnRd;
@property (strong, nonatomic) IBOutlet OrderButton *btnTitle;

@end
