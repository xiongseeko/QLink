//
//  SocketUtil.h
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@protocol SocketUtilDelegate <NSObject>

-(void)success;
-(void)fail;

@end

@interface SocketUtil : NSObject
{
    long udpTag_;
    
    GCDAsyncUdpSocket *udpSocket_;
    GCDAsyncSocket *asyncSocket_;
}

@property(nonatomic,assign) id<SocketUtilDelegate>delegate;

-(void)sendTcp:(NSString *)host
       andPort:(NSString *)port
    andContent:(NSString *)content;

-(void)sendUdp:(NSString *)host
       andPort:(NSString *)port
    andContent:(NSString *)content;

@end
