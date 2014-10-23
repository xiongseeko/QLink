//
//  BaseViewController.h
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataUtil.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

typedef NS_ENUM(NSInteger, SocketType){
    SocketTypeNormal = 1,
    SocketTypeEmergency = 2,
    SocketTypeWriteZk = 3,
    SocketTypeStudy = 4
};

@interface BaseViewController : UIViewController
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,assign) SocketType socketType;
@property(nonatomic,assign) BOOL isSence;
@property(nonatomic,assign) BOOL isAddDeviceSenceZK;

//写入中控，重复尝试 3 次
@property(nonatomic,assign) int iTimeoutCount;

-(void)load_typeSocket:(SocketType)socket andOrderObj:(Order *)order;

@end
