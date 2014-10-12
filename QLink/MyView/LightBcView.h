//
//  LightBcView.h
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightBcView : UIView

@property(nonatomic,strong) IBOutlet UILabel *lTitle;
@property(nonatomic,strong) IBOutlet OrderButton *btnOn;
@property(nonatomic,strong) IBOutlet OrderButton *btnOFF;

@property(nonatomic,strong) IBOutlet UISlider *btnBr;//亮度
@property(nonatomic,strong) IBOutlet UISlider *btnCo;//色调

- (IBAction)btnPressed:(OrderButton *)sender;

@end
