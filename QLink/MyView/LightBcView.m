//
//  LightBcView.m
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "LightBcView.h"

@implementation LightBcView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [_btnBr setThumbImage:[UIImage imageNamed:@"light_roundButton.png"] forState:UIControlStateNormal];
    [_btnCo setThumbImage:[UIImage imageNamed:@"light_roundButton.png"] forState:UIControlStateNormal];
}

-(IBAction)brSliderValueChanged:(UISlider *)slider
{
    float value = slider.value;
    if (0.08 > value > 0) {
        slider.value = 0.05;
    } else if (0.28 > value >= 0.08) {
        slider.value = 0.15;
    } else if(0.42 > value >= 0.28) {
        slider.value = 0.35;
    } else if (0.55 > value >= 0.42) {
        slider.value = 0.5;
    } else if (0.65 > value >= 0.55) {
        slider.value = 0.6;
    } else if (0.75 > value >= 0.65) {
        slider.value = 0.7;
    } else if (0.85 > value >= 0.75) {
        slider.value = 0.8;
    } else if (0.95 > value >= 0.85) {
        slider.value = 0.9;
    } else if (value >= 0.95) {
        slider.value = 1;
    }
    
    NSLog(@"%f",slider.value);
}

-(IBAction)coSliderValueChanged:(UISlider *)slider
{
    float value = slider.value;
    if (0.2 > value > 0) {
        slider.value = 0.2;
    } else if (0.4 > value >= 0.2) {
        slider.value = 0.4;
    } else if(0.6 > value >= 0.4) {
        slider.value = 0.6;
    } else if (0.8 > value >= 0.6) {
        slider.value = 0.8;
    } else if (1 >= value >= 0.8) {
        slider.value = 1;
    }
    NSLog(@"====%f",slider.value);
}

- (IBAction)btnPressed:(OrderButton *)sender
{
    NSLog(@"=====%@",sender.orderObj.OrderName);
}

@end
