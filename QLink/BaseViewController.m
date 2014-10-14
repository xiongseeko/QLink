//
//  BaseViewController.m
//  QLink
//
//  Created by 尤日华 on 14-10-12.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "BaseViewController.h"
#import "NSString+NSStringHexToBytes.h"
#import "NSData+NSDataBytesToHex.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "NetworkUtil.h"
#import "XMLDictionary.h"

#define ECHO_MSG 1
#define READ_TIMEOUT 15.0

@interface BaseViewController ()
{
    //场景，设备参数
    Control *controlObj_;
    Config *configObj_;
    NSString *sendContent_;
    
    //中控参数
    NSMutableArray *cmdReadArr_;
    NSMutableArray *cmdOperArr_;
    NSDictionary *sendCmdDic_;//当前发送的对象
    Control *zkConfig_;
    BOOL isSendZKFailAndSendLast_;
}
@end

@implementation BaseViewController

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

-(void)initDomain
{
    controlObj_ = [SQLiteUtil getControlObj];
}

-(void)initRequestZK1
{
    [self sendSocketOrder];
}

-(void)initRequestZK
{
    self.iTimeoutCount = 1;
    self.isZK = YES;
    isSendZKFailAndSendLast_ = NO;
    
    [SVProgressHUD showWithStatus:@"正在写入中控..."];
    
    NSURL *url = [NSURL URLWithString:[[NetworkUtil getAction:ACTIONSETUPZK] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak __typeof(self)weakSelf = self;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf initSocketOrder];
        });
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

-(void)initSocketOrder
{
    sendCmdDic_ = [cmdOperArr_ objectAtIndex:0];
    sendContent_ = [sendCmdDic_ objectForKey:@"_sdcmd"];
    
    if ([[zkConfig_.SendType lowercaseString] isEqualToString:@"tcp"]) {
        [self initTcp:zkConfig_.Ip andPort:zkConfig_.Port];
//        [self initTcp:@"117.25.254.193" andPort:@"30000"];//@"121.204.154.81"
    }
    else{
        [self sendUdp:zkConfig_.Ip andPort:zkConfig_.Port];
    }
}

-(void)sendSocketOrder
{
    sendCmdDic_ = [cmdOperArr_ objectAtIndex:0];
    sendContent_ = [sendCmdDic_ objectForKey:@"_sdcmd"];
    
    NSData *data = [sendContent_ hexToBytes];
    [asyncSocket_ writeData:data withTimeout:-1 tag:ECHO_MSG];
}

//场景设备发送
-(void)sendSocketOrder:(NSString *)cmd
{
    self.isZK = NO;
    
    configObj_ = [Config getConfig];
    if (configObj_.isBuyCenterControl) {
        [self initDomain];
    }
    
    sendContent_ = cmd;
    
    if (controlObj_) {//中控，远程发送
        if ([[controlObj_.SendType lowercaseString] isEqualToString:@"tcp"]) {
            [self initTcp:controlObj_.Domain andPort:controlObj_.Port];
        }
        else{
            [self sendUdp:controlObj_.Domain andPort:controlObj_.Port];
        }
    }
}

-(void)sendUdp:(NSString *)host
       andPort:(NSString *)port
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
    
//    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
//    //    NSData *data = [self HexConvertToASCII:msg];
//    [udpSocket_ sendData:data toHost:host port:[port integerValue] withTimeout:-1 tag:udpTag_];//传递数据
//    
//    NSLog(@"SENT (%i): %@", (int)udpTag_, content);
    
    udpTag_++;
}

//中控发送
-(void)initTcp:(NSString *)host
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
    
    NSData *data = [sendContent_ hexToBytes];
    
    [asyncSocket_ writeData:data withTimeout:-1 tag:ECHO_MSG];//发送数据;  withTimeout:超时时间，设置为－1代表永不超时;  tag:区别该次读取与其他读取的标志,通常我们在设计视图上的控件时也会有这样的一个属性就是tag;
}

//未成功连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        if (self.isZK) {
            if (NumberOfTimeout > [self iTimeoutCount]) {
                [self setITimeoutCount:[self iTimeoutCount] + 1];
                sleep(1);
                [self initSocketOrder];
            } else if ([self iTimeoutCount] >= NumberOfTimeout) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                    message:@"写入中控失败,请重试." delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"重试", nil];
                alert.tag = 999;
                [alert show];
                
                [SVProgressHUD dismiss];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"连接服务器失败."
                                                           delegate:nil
                                                  cancelButtonTitle:@"关闭"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"连接失败\n");
        NSLog(@"错误信息 －－ socketDidDisconnect:%p withError: %@", sock, err);
    }else{
        NSLog(@"断开连接\n");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (_isZK) {
        [sock readDataWithTimeout:3 tag:-1];
    } else {
        [self disConnectionTCP];
    }
}

//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *bkcCmd = [[sendCmdDic_ objectForKey:@"_bkcmd"] hexToBytes];
    NSData *top3Cmd = [bkcCmd subdataWithRange:NSMakeRange(0, 3)];
    NSData *readTop3 = [data subdataWithRange:NSMakeRange(0, 3)];

    if ([top3Cmd isEqualToData: readTop3])
    {
        [cmdOperArr_ removeObject:sendCmdDic_];
        
        NSLog(@"====%d",[cmdOperArr_ count]);
        
        //发送完成，关闭连接
        if ([cmdOperArr_ count] == 0) {
            
            if (!isSendZKFailAndSendLast_) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                    message:@"写入中控成功."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
            
            [self disConnectionTCP];
            [SVProgressHUD dismiss];
            
            return;
        }
        
        self.iTimeoutCount = 1;
        [self sendSocketOrder];
    }
    else
    {
        if (NumberOfTimeout > [self iTimeoutCount]) {
            [self setITimeoutCount:[self iTimeoutCount] + 1];
            [self sendSocketOrder];
        } else if ([self iTimeoutCount] >= NumberOfTimeout) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"写入中控失败,请重试." delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"重试", nil];
            alert.tag = 999;
            [alert show];
            
            [SVProgressHUD dismiss];
        }
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {//关闭
            isSendZKFailAndSendLast_ = YES;
            
            sendCmdDic_ = [cmdOperArr_ lastObject];
            [cmdOperArr_ removeAllObjects];
            [cmdOperArr_ addObject:sendCmdDic_];
            
            [self sendSocketOrder];
        } else if (buttonIndex == 1) {//重试
            [SVProgressHUD showWithStatus:@"正在写入中控..."];
            
            cmdOperArr_ = [NSMutableArray arrayWithArray:cmdReadArr_];
            self.iTimeoutCount = 1;
            [self initSocketOrder];
        }
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
