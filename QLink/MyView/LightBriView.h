//
//  LightBriView.h
//  QLink
//
//  Created by SANSAN on 14-9-28.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LightBriViewDelegate <NSObject>

-(void)orderDelegatePressed:(OrderButton *)sender;

@end

@interface LightBriView : UIView


@property(nonatomic,assign) id<LightBriViewDelegate>delegate;
@property(nonatomic,strong) IBOutlet UILabel *lTitle;
@property(nonatomic,strong) IBOutlet OrderButton *btnOn;
@property(nonatomic,strong) IBOutlet OrderButton *btnOff;
@property (strong, nonatomic) IBOutlet UISlider *sliderLight;

@property(nonatomic,strong) NSArray *brOrderArr;

- (IBAction)btnPressed:(OrderButton *)sender;

@end
