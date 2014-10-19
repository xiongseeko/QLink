//
//  SetupIpViewController.h
//  QLink
//
//  Created by 尤日华 on 14-10-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "SimplePingHelper.h"

@interface SetupIpViewController : UIViewController<SimplePingDelegate>
{
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,assign) int iTimeoutCount;

-(void)load_setIpSocket:(NSDictionary *)dic;

@end
