//
//  NetworkUtil.m
//  QLink
//
//  Created by 尤日华 on 14-9-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "NetworkUtil.h"
#import "DataUtil.h"

@implementation NetworkUtil

//获取基础 Url
+(NSString *)getBaseUrl
{
    Member *member = [Member getMember];
    
    return [NSString stringWithFormat:@"http://qlink.cc/zq/lookmobile.asp?uname=%@&upsd=%@&passkey=%@",member.uName,member.uPwd,member.uKey];
}

//获取 Action = login Url
+(NSString *)getActionLogin:(NSString *)uName
                    andUPwd:(NSString *)uPwd
                    andUKey:(NSString *)uKey
{
    return [NSString stringWithFormat:@"http://qlink.cc/zq/lookmobile.asp?uname=%@&upsd=%@&passkey=%@&action=login",uName,uPwd,uKey];
}

//获取 Action URL
+(NSString *)getAction:(NSString *)action
{
    return [NSString stringWithFormat:@"%@&action=%@",[self getBaseUrl],action];
}


//修改场景URL
+(NSString *)getChangeSenceName:(NSString *)newName andSenceId:(NSString *)senceId
{
    return [NSString stringWithFormat:@"%@&action=savekfchang&dx=2&classname=macro&Id=%@&ChangVar=%@",[self getBaseUrl],senceId,newName];
}

//修改设备URL
+(NSString *)getChangeDeviceName:(NSString *)newName andDeviceId:(NSString *)deviceId
{
    return [NSString stringWithFormat:@"%@&action=savekfchang&dx=1&Id=%@&ChangVar=%@",[self getBaseUrl],deviceId,newName];
}

//http://www.qlink.cc/zq/lookmobile.asp?uname=15711515119&upsd=15711515119&passkey=26,69,93,21&action=savekfchang&dx=2&ChangVar=刘MM的电视场景&Id=40963&classname=macro

//http://www.qlink.cc/zq/lookmobile.asp?uname=15711515119&upsd=15711515119&passkey=26,69,93,21&action=savekfchang&dx=1&ChangVar=test&Id=2328

@end
