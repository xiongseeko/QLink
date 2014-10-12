//
//  ZKViewController.h
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface ZKViewController : UIViewController<UIAlertViewDelegate>
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,assign) int iRetryCount;

-(void)initZhongKong;

-(void)sendUdp:(NSString *)host
       andPort:(NSString *)port
    andContent:(NSString *)content;

-(void)sendTcp:(NSString *)host
       andPort:(NSString *)port;
@end
