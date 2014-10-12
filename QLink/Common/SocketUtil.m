//
//  SocketUtil.m
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "SocketUtil.h"

#define ECHO_MSG 1
#define READ_TIMEOUT 15.0

@implementation SocketUtil

-(void)sendUdp:(NSString *)host
       andPort:(NSString *)port
    andContent:(NSString *)content
{
    /**************创建连接**************/
    
    udpSocket_ = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	NSError *error = nil;
    //连接API
	if (![udpSocket_ bindToPort:0 error:&error])
	{
        NSLog(@"Error binding: %@", error);
		return;
	}
    //接收数据API
	if (![udpSocket_ beginReceiving:&error])
	{
		NSLog(@"Error receiving: %@", error);
		return;
	}
	
	NSLog(@"udp连接成功");
    
    /**************发送数据**************/
    
    NSData *data = [content dataUsingEncoding:NSASCIIStringEncoding];
    //    NSData *data = [self HexConvertToASCII:msg];
    [udpSocket_ sendData:data toHost:host port:[port integerValue] withTimeout:-1 tag:udpTag_];//传递数据
    
    NSLog(@"SENT (%i): %@", (int)udpTag_, content);
    
    udpTag_++;
}

-(void)sendTcp:(NSString *)host
       andPort:(NSString *)port
    andContent:(NSString *)content
{
    /**************创建连接**************/
    
    if (asyncSocket_ == nil)
        asyncSocket_ = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![asyncSocket_ connectToHost:host onPort:[port integerValue] error:&error])
    {
        NSLog(@"Error connecting: %@", error);
        
        return;
    }
    
    /**************发送数据**************/
    
    content = [NSString stringWithFormat:@"%@\r\n", content];
    NSData *data = [content dataUsingEncoding:NSASCIIStringEncoding];
    
    [asyncSocket_ writeData:data withTimeout:-1 tag:ECHO_MSG];//发送数据;  withTimeout:超时时间，设置为－1代表永不超时;  tag:区别该次读取与其他读取的标志,通常我们在设计视图上的控件时也会有这样的一个属性就是tag;
}

#pragma mark -
#pragma mark UDP 响应方法

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

//接收UDP数据
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if (msg)
	{
		NSLog(@"RECV: %@", msg);
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		
		NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
	}
}

#pragma mark -
#pragma mark TCP 响应方法

//当成功连接上，delegate 的 socket:didConnectToHost:port: 方法会被调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"连接成功\n");
	NSLog(@"已连接到 －－ socket:%p didConnectToHost:%@ port:%hu \n", sock, host, port);
    
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //	NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];//?????
}

//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSASCIIStringEncoding];
    
    if (msg)
    {
        NSLog(@"%@", msg);
        
    }
    else
    {
        NSLog(@"Error converting received data into UTF-8 String");
    }
    
    [self disConnectionTCP];
}

//未成功连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        NSLog(@"连接失败\n");
        NSLog(@"错误信息 －－ socketDidDisconnect:%p withError: %@", sock, err);
    }else{
        NSLog(@"断开连接\n");
    }
}

#pragma mark -
#pragma mark 自定义方法

//断开释放一个连接实例
-(void)disConnectionTCP
{
    //    [asyncSocket_ setDelegate:nil delegateQueue:NULL];
    [asyncSocket_ disconnect];
}

-(void)disConnectionUDP
{
    [udpSocket_ setDelegate:nil delegateQueue:NULL];
    [udpSocket_ close];
}

@end
