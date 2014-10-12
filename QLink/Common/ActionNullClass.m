//
//  ActionNullClass.m
//  QLink
//
//  Created by 尤日华 on 14-10-4.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "ActionNullClass.h"
#import "MyURLConnection.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"
#import "DataUtil.h"
#import "XMLDictionary.h"

@implementation ActionNullClass

-(id)init
{
    self = [super init];
    if (self) {
        self.iRetryCount = 1;
    }
    
    return self;
}

//配置文件请求
-(void)initRequestActionNULL
{
    [SVProgressHUD showWithStatus:@"正在解析..."];
    
    NSString *sUrl = [NetworkUtil getBaseUrl];
    NSURL *url = [NSURL URLWithString:sUrl];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:50];
    MyURLConnection *connection = [[MyURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self];
    connection.sTag = ACTIONNULL;
    
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
    
    if (NumberOfTimeout > [self iRetryCount]) {
        [self setIRetryCount:[self iRetryCount] + 1];
        [self initRequestActionNULL];
    } else if ([self iRetryCount] == NumberOfTimeout) {
        [SVProgressHUD dismiss];
        
        if (self.delegate) {
            [self.delegate failOper];
        }
    }
}
- (void)connectionDidFinishLoading: (MyURLConnection*)connection
{
    //清除本地配置数据
    [SQLiteUtil clearData];
    
    NSString *strXML = [[NSString alloc] initWithData:responseData_ encoding:[DataUtil getGB2312Code]];
    
    if ([strXML isEqualToString:@"key error"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"解析出错,请重试."
                                                       delegate:nil
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        [SVProgressHUD dismiss];
        return;
    }
    
    strXML = [strXML stringByReplacingOccurrencesOfString:@"\"GB2312\"" withString:@"\"utf-8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,40)];
    NSData *newData = [strXML dataUsingEncoding:NSUTF8StringEncoding];
    
    //解析存到数据库
    NSMutableArray *sqlArr = [NSMutableArray array];
    NSDictionary *dict = [NSDictionary dictionaryWithXMLData:newData];
    
    if (!dict) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"解析出错,请重试."
                                                       delegate:nil
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        [SVProgressHUD dismiss];
        return;
    }
    //配置表
    NSDictionary *info = [dict objectForKey:@"info"];
    Control *controlObj = [Control setIp:[info objectForKey:@"_ip"]
                             andSendType:[info objectForKey:@"_tu"]
                                 andPort:[info objectForKey:@"_port"]
                               andDomain:[info objectForKey:@"_domain"]
                                  andUrl:[info objectForKey:@"_url"]
                            andUpdatever:[info objectForKey:@"_updatever"]];
    [sqlArr addObject:[SQLiteUtil connectControlSql:controlObj]];
    
    NSArray *layerArr = [DataUtil changeDicToArray:[info objectForKey:@"layer"]];
    for (NSDictionary *layerDic in layerArr) {
        //room
        NSArray *roomArr = [DataUtil changeDicToArray:[layerDic objectForKey:@"room"]];
        for (NSDictionary *roomDic in roomArr) {
            Room *roomObj = [Room setRoomId:[roomDic objectForKey:@"_Id"]
                                andRoomName:[roomDic objectForKey:@"_name"]
                                 andHouseId:[roomDic objectForKey:@"_houseid"]
                                 andLayerId:[roomDic objectForKey:@"_layerId"]];
            [sqlArr addObject:[SQLiteUtil connectRoomSql:roomObj]];
            
            //device
            NSArray *deviceArr = [DataUtil changeDicToArray:[roomDic objectForKey:@"device"]];
            for (NSDictionary *deviceDic in deviceArr) {
                if ([[deviceDic objectForKey:@"_type"] isEqualToString:MACRO]) {
                    Sence *senceObj = [Sence setSenceId:[deviceDic objectForKey:@"_id"]
                                           andSenceName:[deviceDic objectForKey:@"_name"]
                                            andMacrocmd:[deviceDic objectForKey:@"_macrocmd"]
                                                andType:[deviceDic objectForKey:@"_type"]
                                             andCmdList:[deviceDic objectForKey:@"_cmdlist"]
                                             andHouseId:[deviceDic objectForKey:@"_houseid"]
                                             andLayerId:[deviceDic objectForKey:@"_layerId"]
                                              andRoomId:[deviceDic objectForKey:@"_roomId"]
                                            andIconType:@""];
                    [sqlArr addObject:[SQLiteUtil connectSenceSql:senceObj]];
                }else{
                    Device *deviceObj = [Device setDeviceId:[deviceDic objectForKey:@"_id"]
                                              andDeviceName:[deviceDic objectForKey:@"_name"]
                                                    andType:[deviceDic objectForKey:@"_type"]
                                                 andHouseId:[deviceDic objectForKey:@"_houseid"]
                                                 andLayerId:[deviceDic objectForKey:@"_layerId"]
                                                  andRoomId:[deviceDic objectForKey:@"_roomId"]
                                                andIconType:@""];
                    [sqlArr addObject:[SQLiteUtil connectDeviceSql:deviceObj]];
                    
                    //order
                    NSArray *orderArr = [DataUtil changeDicToArray:[deviceDic objectForKey:@"order"]];
                    for (NSDictionary *orderDic in orderArr) {
                        NSString *studyCmd = [orderDic objectForKey:@"_studycmd"];
                        if ([DataUtil checkNullOrEmpty:studyCmd]) {
                            studyCmd = @"";
                        }
                        Order *orderObj = [Order setOrderId:[orderDic objectForKey:@"_id"]
                                               andOrderName:[orderDic objectForKey:@"_name"]
                                                    andType:[orderDic objectForKey:@"_type"]
                                                 andSubType:[orderDic objectForKey:@"_subtype"]
                                                andOrderCmd:[orderDic objectForKey:@"_ordercmd"]
                                                 andAddress:[orderDic objectForKey:@"_ades"]
                                                andStudyCmd:studyCmd
                                                 andOrderNo:[orderDic objectForKey:@"_sn"]
                                                 andHouseId:[orderDic objectForKey:@"_houseid"]
                                                 andLayerId:[orderDic objectForKey:@"_layerId"]
                                                  andRoomId:[orderDic objectForKey:@"_roomId"]
                                                andDeviceId:[orderDic objectForKey:@"_deviceid"]];
                        [sqlArr addObject:[SQLiteUtil connectOrderSql:orderObj]];
                    }
                }
            }
        }
    }
    
    BOOL bResult = [SQLiteUtil handleConfigToDataBase:sqlArr];
    if (bResult) {
        if (self.delegate) {
            [self.delegate successOper];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"解析失败,请重试."
                                                           delegate:nil
                                                  cancelButtonTitle:@"关闭"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        
        [SVProgressHUD dismiss];
    }
}

- (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data,
                                                               kCFPropertyListImmutable,
                                                               NULL);
    if(plist == nil) return nil;
    if ([(__bridge id)plist isKindOfClass:[NSDictionary class]]) {
        return (__bridge NSDictionary *)plist;
    }
    else {
        CFRelease(plist);
        return nil;
    }
}

@end
