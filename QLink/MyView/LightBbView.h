//
//  LightBbView.h
//  QLink
//
//  Created by SANSAN on 14-9-28.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LightBbViewDelegate <NSObject>

-(void)orderDelegatePressed:(OrderButton *)sender;

@end

@interface LightBbView : UIView

@property(nonatomic,assign) id<LightBbViewDelegate>delegate;

@property(nonatomic,strong) IBOutlet UILabel *lTitle;
@property(nonatomic,strong) IBOutlet OrderButton *btnOn;
@property(nonatomic,strong) IBOutlet OrderButton *btnOff;
@property(nonatomic,strong) IBOutlet OrderButton *btnUp;
@property(nonatomic,strong) IBOutlet OrderButton *btnDown;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK1;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK2;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK3;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK4;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK5;
@property(nonatomic,strong) IBOutlet OrderButton *btnFK6;


- (IBAction)btnPressed:(OrderButton *)sender;
- (IBAction)btnLightPressed:(OrderButton *)sender;
-(IBAction)btnColorPressed:(OrderButton *)sender;

@end
