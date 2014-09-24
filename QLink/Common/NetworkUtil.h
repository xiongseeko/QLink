//
//  NetworkUtil.h
//  QLink
//
//  Created by 尤日华 on 14-9-19.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtil : NSObject

+(NSString *)getBaseUrl;

//获取 Action = login Url
+(NSString *)getActionLogin:(NSString *)uName
                    andUPwd:(NSString *)uPwd
                    andUKey:(NSString *)uKey;

//获取 Action URL
+(NSString *)getAction:(NSString *)action;

//修改场景URL
+(NSString *)getChangeSenceName:(NSString *)newName andSenceId:(NSString *)senceId;

//修改设备URL
+(NSString *)getChangeDeviceName:(NSString *)newName andDeviceId:(NSString *)deviceId;

@end
