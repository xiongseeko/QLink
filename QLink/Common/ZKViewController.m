//
//  ZKViewController.m
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "ZKViewController.h"
#import "DataUtil.h"
#import "NSString+NSStringHexToBytes.h"
#import "SVProgressHUD.h"
#import "NetworkUtil.h"
#import "XMLDictionary.h"
#import "AFNetworking.h"

#define ECHO_MSG 1
#define READ_TIMEOUT 15.0

@interface ZKViewController ()
{
    NSMutableArray *cmdReadArr_;
    NSMutableArray *cmdOperArr_;
    
    NSDictionary *sendCmdDic_;//当前发送的对象
    
    Control *zkConfig_;
}
@end

@implementation ZKViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)initZhongKong
{
    [self sendSocketOrder];
}

-(void)initZhongKong1
{
    [SVProgressHUD showWithStatus:@"正在写入中控..."];
    
    self.iRetryCount = 1;
    
    NSURL *url = [NSURL URLWithString:[[NetworkUtil getAction:ACTIONSETUPZK] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *strXML = operation.responseString;
        
        strXML = [strXML stringByReplacingOccurrencesOfString:@"\"GB2312\"" withString:@"\"utf-8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,40)];
        NSData *newData = [strXML dataUsingEncoding:NSUTF8StringEncoding];
        
        //设置发送host
        NSDictionary *dict = [NSDictionary dictionaryWithXMLData:newData];
        NSDictionary *info = [dict objectForKey:@"info"];
        zkConfig_ = [[Control alloc] init];
        zkConfig_.Ip = [info objectForKey:@"_ip"];
        zkConfig_.SendType = [info objectForKey:@"_tu"];
        zkConfig_.Port = [info objectForKey:@"_port"];
        
        //拼接队列
        cmdReadArr_ = [NSMutableArray arrayWithArray:[DataUtil changeDicToArray:[info objectForKey:@"tecom"]]];
        cmdOperArr_ = [NSMutableArray arrayWithArray:cmdReadArr_];
        
        if ([cmdOperArr_ count] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"没有定义中控命令." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self sendSocketOrder];
//        });
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

#pragma mark -
#pragma mark Socket

-(void)sendSocketOrder1
{
    sendCmdDic_ = [NSDictionary dictionaryWithObjectsAndKeys:@"5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A",@"sdcmd",@"3055C50F",@"bkcmd", nil]; // [cmdOperArr_ objectAtIndex:0];
    
    [self sendTcp:@"117.25.254.193" andPort:@"30000"];
    
//    if ([[zkConfig_.SendType lowercaseString] isEqualToString:@"tcp"]) {
//        [self sendTcp:zkConfig_.Ip andPort:zkConfig_.Port];
//    }
//    else{
//        [self sendUdp:zkConfig_.Ip andPort:zkConfig_.Port andContent:[sendCmdDic_ objectForKey:@"sdcmd"]];
//    }
}

-(void)sendSocketOrder
{
    [self sendTcp:@"117.25.254.193" andPort:@"30000"];
}

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
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData *data = [self HexConvertToASCII:msg];
    [udpSocket_ sendData:data toHost:host port:[port integerValue] withTimeout:-1 tag:udpTag_];//传递数据
    
    NSLog(@"SENT (%i): %@", (int)udpTag_, content);
    
    udpTag_++;
}

-(void)sendTcp:(NSString *)host
       andPort:(NSString *)port
{
    /**************创建连接**************/
    
    asyncSocket_ = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![asyncSocket_ connectToHost:host onPort:[port integerValue] error:&error])
    {
        NSLog(@"Error connecting");
        return;
    }
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
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
    NSLog(@"＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝\n");
    NSLog(@"连接成功\n");
	NSLog(@"已连接到 －－ socket:%p didConnectToHost:%@ port:%hu \n", sock, host, port);
    
    NSData *data = [@"5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A" hexToBytes];
    
    [asyncSocket_ writeData:data withTimeout:-1 tag:ECHO_MSG];//发送数据;  withTimeout:超时时间，设置为－1代表永不超时;  tag:区别该次读取与其他读取的标志,通常我们在设计视图上的控件时也会有这样的一个属性就是tag;
}

//未成功连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"连接服务器失败."
                                                       delegate:nil
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        NSLog(@"连接失败\n");
        NSLog(@"错误信息 －－ socketDidDisconnect:%p withError: %@", sock, err);
    }else{
        NSLog(@"断开连接\n");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self disConnectionTCP];
    
    //	NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    
    //    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
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

#pragma mark -
#pragma mark Custom Methods

//断开释放一个连接实例
-(void)disConnectionTCP
{
    [asyncSocket_ disconnect];
}

-(void)disConnectionUDP
{
    [udpSocket_ setDelegate:nil delegateQueue:NULL];
    [udpSocket_ close];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
