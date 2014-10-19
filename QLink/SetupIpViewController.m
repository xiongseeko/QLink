//
//  SetupIpViewController.m
//  QLink
//
//  Created by 尤日华 on 14-10-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "SetupIpViewController.h"
#import "DataUtil.h"
#import "NSString+NSStringHexToBytes.h"

@interface SetupIpViewController ()
{
    NSMutableArray *infoTagReadArr_;
    NSMutableArray *infoTagArr_;
    NSMutableArray *orderDicArr_;
    
    NSString *sendContent_;
    NSDictionary *sendDic_;
}
@end

@implementation SetupIpViewController

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
    // Do any additional setup after loading the view.
}

-(void)load_setIpSocket:(NSDictionary *)dic
{
    self.iTimeoutCount = 1;
    
    NSDictionary *info = [dic objectForKey:@"info"];
    
    infoTagReadArr_ = [NSMutableArray arrayWithObjects:@"onecmd",@"twocmd",@"threecmd",@"send_this_cmd",@"send_this_cmd1",@"send_this_cmd2", nil];
    
    orderDicArr_ = [NSMutableArray arrayWithArray:[DataUtil changeDicToArray:[info objectForKey:@"kfsdevice"]]];
    [orderDicArr_ insertObject:info atIndex:0];
    
    [self sendLoopOrder];
}

-(void)sendLoopOrder
{
    infoTagArr_ = [NSMutableArray arrayWithArray:infoTagArr_];
    sendDic_ = [orderDicArr_ objectAtIndex:0];
    
    [self sendLoopTag];
}

-(void)sendLoopTag
{
    for (NSString *tag in infoTagReadArr_) {
        sendContent_ = [sendDic_ objectForKey:tag];
        if ([DataUtil checkNullOrEmpty:sendContent_]) {
            [infoTagArr_ removeObject:tag];
        } else {
            break;
        }
    }
    
    NSString *toHera = [DataUtil checkNullOrEmpty:[sendDic_ objectForKey:@"to_here"]] ? [sendDic_ objectForKey:@"toip"] : [sendDic_ objectForKey:@"to_here"];
    NSArray *to_hereArr = [toHera componentsSeparatedByString:@":"];
    NSArray *local_portArr = [[sendDic_ objectForKey:@"to_here"] componentsSeparatedByString:@":"];

    [self initUdp:[to_hereArr objectAtIndex:1]
          andPort:[to_hereArr objectAtIndex:2]
      andBindPort:[local_portArr objectAtIndex:1]
     andBroadcast:YES];
}

#pragma mark -
#pragma mark 发送方法（UDP／TCP）

-(void)initUdp:(NSString *)host
       andPort:(NSString *)port
   andBindPort:(NSString *)bindPort
  andBroadcast:(BOOL)enable
{
    /**************创建连接**************/
    
    udpSocket_ = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	NSError *error = nil;
	if (bindPort != nil && ![udpSocket_ bindToPort:[bindPort integerValue] error:&error])
	{
        NSLog(@"Error binding: %@", error);
		return;
	}
	if (![udpSocket_ beginReceiving:&error])
	{
		NSLog(@"Error receiving: %@", error);
		return;
	}
    if (enable && ![udpSocket_ enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", error);
		return;
    }
    
    /**************发送数据**************/
    
    NSData *data = [sendContent_ hexToBytes];
    [udpSocket_ sendData: data toHost: host port: [port integerValue] withTimeout:-1 tag: -1];
}

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
    [NSThread sleepForTimeInterval:0.5];
    
    // 移除命令
    [infoTagArr_ removeObject:0];
    
    // 发完完毕, ping一下
    if ([infoTagArr_ count] == 0) {
        NSArray *testIpArr = [[sendDic_ objectForKey:@"testip"] componentsSeparatedByString:@":"];
        NSString *pingIp = nil;
        if ([testIpArr count] > 0) {
            pingIp = [testIpArr objectAtIndex:1];
        } else {
            pingIp =[sendDic_ objectForKey:@"testip"];
        }
        
        [SimplePingHelper ping:pingIp
                        target:self
                           sel:@selector(pingResult:)];
    } else {
        [self sendLoopTag];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [self pingFailure];
}

//接收UDP数据
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    
}

#pragma mark -
#pragma mark TCP 响应方法

//当成功连接上，delegate 的 socket:didConnectToHost:port: 方法会被调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝\n");
    NSLog(@"连接成功\n");
	NSLog(@"已连接到 －－ socket:%p didConnectToHost:%@ port:%hu \n", sock, host, port);
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

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
}

-(void) pingSuccess
{
    self.iTimeoutCount = 1;
    [orderDicArr_ removeObject:0];
    [self sendLoopOrder];
}

-(void) pingFailure
{
    if (NumberOfTimeout > [self iTimeoutCount]) {
        [self setITimeoutCount:[self iTimeoutCount] + 1];
        [self sendLoopOrder];
    } else if ([self iTimeoutCount] >= NumberOfTimeout) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"配置ip失败." delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark SimpDel

- (void)pingResult:(NSNumber*)success {
    if (success.boolValue) {
        [self pingSuccess];
    } else {
        [self pingFailure];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
