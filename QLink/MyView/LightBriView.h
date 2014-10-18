//
//  LightBriView.h
//  QLink
//
//  Created by SANSAN on 14-9-28.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightBriView : UIView

@property(nonatomic,strong) IBOutlet UILabel *lTitle;
@property(nonatomic,strong) IBOutlet OrderButton *btnOn;
@property(nonatomic,strong) IBOutlet OrderButton *btnOff;
@property (strong, nonatomic) IBOutlet UISlider *sliderLight;

@property(nonatomic,strong) NSArray *orderArr;

- (IBAction)btnPressed:(OrderButton *)sender;

@end
