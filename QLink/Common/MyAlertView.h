//
//  MyAlertView.h
//  QLink
//
//  Created by SANSAN on 14-9-23.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAlertView : UIAlertView

//长按参数
@property(nonatomic,strong) NSString *pType;
@property(nonatomic,assign) int pIndex;

//删除参数
@property(nonatomic,strong) NSString *pDeviceId;

@end
