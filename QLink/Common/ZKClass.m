//
//  ZKClass.m
//  QLink
//
//  Created by 尤日华 on 14-10-4.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "ZKClass.h"
#import "MyURLConnection.h"
#import "XMLDictionary.h"
#import "DataUtil.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"

@implementation ZKClass

-(id)init
{
    self = [super init];
    if (self) {
        self.iRetryCount = 1;
    }
    
    return self;
}

-(void)initZhongKong
{
    [SVProgressHUD showWithStatus:@"正在写入中控..."];
    
    NSURL *url = [NSURL URLWithString:[NetworkUtil getAction:ACTIONSETUPZK]];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    MyURLConnection *connection = [[MyURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self];
    connection.sTag = ACTIONSETUPZK;
    
    if (connection) {
        responseData_ = [NSMutableData new];
    }
}

#pragma mark -
#pragma mark NSURLConnection 回调方法
- (void)connection:(MyURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData_ appendData:data];
}
-(void) connection:(MyURLConnection *)connection didFailWithError: (NSError *)error
{
    NSLog(@"====fail");
    
    [connection cancel];
    
    if ([connection.sTag isEqualToString:ACTIONSETUPZK]) {
        if (iNumberOfTimesToRetryOnTimeout > [self iRetryCount]) {
            [self setIRetryCount:[self iRetryCount] + 1];
            [self initZhongKong];
        } else if ([self iRetryCount] == iNumberOfTimesToRetryOnTimeout) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"写入中控失败,请重试." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alertView show];
            
            [SVProgressHUD dismiss];
        }
    }
}
- (void)connectionDidFinishLoading: (MyURLConnection*)connection
{
    NSDictionary *dict = [NSDictionary dictionaryWithXMLData:responseData_];
    
    NSDictionary *info = [dict objectForKey:@"info"];
    NSString *ip = [info objectForKey:@"_ip"];
    NSString *tu = [info objectForKey:@"_tu"];
    NSString *port = [info objectForKey:@"_port"];
    
    NSArray *tecomArr = [DataUtil changeDicToArray:[info objectForKey:@"tecom"]];
    NSLog(@"=====%d",[tecomArr count]);
    
    [SVProgressHUD dismiss];

    if (self.delegate) {
        [self.delegate successZKOper];
    }
}



@end
