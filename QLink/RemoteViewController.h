//
//  RemoteViewController.h
//  QLink
//
//  Created by SANSAN on 14-9-25.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwView.h"
#import "DtView.h"
#import "McView.h"
#import "PlView.h"
#import "SdView.h"
#import "OtView.h"
#import "HsView.h"
#import "NmView.h"
#import "BsTcView.h"
#import "TrView.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface RemoteViewController : UIViewController<SwViewDelegate,DtViewDelegate,McViewDelegate,PlViewDelegate,SdViewDelegate,OtViewDelegate,HsViewDelegate,NmViewDelegate,BsTcViewDelegate,TrViewDelegate,UIAlertViewDelegate>
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,strong) NSString *deviceId;
@property(nonatomic,strong) NSString *deviceName;

@end
