//
//  LightViewController.h
//  QLink
//
//  Created by SANSAN on 14-9-28.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwView1.h"
#import "RenameView.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface LightViewController : UIViewController<Sw1Delegate,RenameViewDelegate>
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@end
