//
//  DataUtil.m
//  QLink
//
//  Created by SANSAN on 14-9-20.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "DataUtil.h"
#import "FMDatabase.h"

@implementation DataUtil

//获取沙盒地址
+(NSString *)getDirectoriesInDomains
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}

//检测是否为空
+(BOOL)checkNullOrEmpty:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//判断节点类型并且转换为数组
+(NSArray *)changeDicToArray:(NSObject *)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSArray arrayWithObject:(NSDictionary *)obj];
    }else
    {
        return (NSArray *)obj;
    }
}

@end

/************************************************************************************/

@implementation Member

//获取Ud对象用户信息
+(Member *)getMember
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *memberDict = [ud objectForKey:@"MEMBER_UD"];
    if (!memberDict) {
        return nil;
    }
    
    Member *memberObj = [[Member alloc] init];
    memberObj.uName = [memberDict objectForKey:@"uName"];
    memberObj.uPwd = [memberDict objectForKey:@"uPwd"];
    memberObj.uKey = [memberDict objectForKey:@"uKey"];
    memberObj.isRemeber = [[memberDict objectForKey:@"isRemeber"] boolValue];
    
    return memberObj;
}

//设置对象信息
+(void)setUdMember:(NSString *)uName
           andUPwd:(NSString *)uPwd
           andUKey:(NSString *)uKey
      andIsRemeber:(BOOL)isRemeber
{
    NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] init];
    [memberDict setObject:uName forKey:@"uName"];
    [memberDict setObject:uPwd forKey:@"uPwd"];
    [memberDict setObject:uKey forKey:@"uKey"];
    [memberDict setObject:[NSNumber numberWithBool:isRemeber] forKey:@"isRemeber"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:memberDict forKey:@"MEMBER_UD"];
    [ud synchronize];
}

@end

/************************************************************************************/

@implementation Config

//获取配置信息
+(Config *)getConfig
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *objDic = [ud objectForKey:@"CONFIG_UD"];
    if (!objDic) {
        return nil;
    }
    
    Config *obj = [[Config alloc] init];
    obj.configVersion = [objDic objectForKey:@"configVersion"];
    obj.isSetSign = [[objDic objectForKey:@"isSetSign"] boolValue];
    obj.isWriteCenterControl = [[objDic objectForKey:@"isWriteCenterControl"] boolValue];
    obj.isSetIp = [[objDic objectForKey:@"isSetIp"] boolValue];
    obj.isBuyCenterControl = [[objDic objectForKey:@"isBuyCenterControl"] boolValue];
    
    return obj;
}

//设置配置信息
+(void)setConfigArr:(NSArray *)configArr
{
    NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] init];
    
    //配置文件版本
    [memberDict setObject:[configArr objectAtIndex:1] forKey:@"configVersion"];
    
    //是否配置过标记，未配置则强制进入配置模式
    NSString *sIsSetSign = [configArr objectAtIndex:3];
    BOOL bIsSetSign = NO;
    if ([[sIsSetSign uppercaseString] isEqualToString:@"TRUE"]) {
        bIsSetSign = YES;
    }
    [memberDict setObject:[NSNumber numberWithBool:bIsSetSign] forKey:@"isSetSign"];
    
    //是否写入中控
    NSString *sIsWriteCenterControl = [configArr objectAtIndex:4];
    BOOL bIsWriteCenterControl = NO;
    if ([[sIsWriteCenterControl uppercaseString] isEqualToString:@"TRUE"]) {
        bIsWriteCenterControl = YES;
    }
    [memberDict setObject:[NSNumber numberWithBool:bIsWriteCenterControl] forKey:@"isWriteCenterControl"];
    
    //是否设置 IP
    NSString *sIsSetIp = [configArr objectAtIndex:5];
    BOOL bIsSetIp = NO;
    if ([[sIsSetIp uppercaseString] isEqualToString:@"TRUE"]) {
        bIsSetIp = YES;
    }
    [memberDict setObject:[NSNumber numberWithBool:bIsSetIp] forKey:@"isSetIp"];
    
    //是否购买中控
    NSString *sIsBuyCenterControl = [configArr objectAtIndex:6];
    BOOL bIsBuyCenterControl = NO;
    if ([[sIsBuyCenterControl uppercaseString] isEqualToString:@"TRUE"]) {
        bIsBuyCenterControl = YES;
    }
    [memberDict setObject:[NSNumber numberWithBool:bIsBuyCenterControl]forKey:@"isBuyCenterControl"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:memberDict forKey:@"CONFIG_UD"];
    [ud synchronize];
}

//设置配置信息
+(void)setConfigObj:(Config *)obj
{
    NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] init];
    
    //配置文件版本
    [memberDict setObject:obj.configVersion forKey:@"configVersion"];
    
    //是否配置过标记，未配置则强制进入配置模式
    [memberDict setObject:[NSNumber numberWithBool:obj.isSetSign] forKey:@"isSetSign"];
    
    //是否写入中控
    [memberDict setObject:[NSNumber numberWithBool:obj.isWriteCenterControl] forKey:@"isWriteCenterControl"];
    
    //是否设置 IP
    [memberDict setObject:[NSNumber numberWithBool:obj.isSetIp] forKey:@"isSetIp"];
    
    //是否购买中控
    [memberDict setObject:[NSNumber numberWithBool:obj.isBuyCenterControl]forKey:@"isBuyCenterControl"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:memberDict forKey:@"CONFIG_UD"];
    [ud synchronize];
}

//临时变量,用于对比本地配置属性
+(Config *)getTempConfig:(NSArray *)configArr
{
    Config *obj = [[Config alloc] init];
    
    obj.configVersion = [configArr objectAtIndex:1];
    
    //是否配置过标记，未配置则强制进入配置模式
    NSString *sIsSetSign = [configArr objectAtIndex:3];
    BOOL bIsSetSign = NO;
    if ([[sIsSetSign uppercaseString] isEqualToString:@"TRUE"]) {
        bIsSetSign = YES;
    }
    obj.isSetSign = bIsSetSign;
    
    //是否写入中控
    NSString *sIsWriteCenterControl = [configArr objectAtIndex:4];
    BOOL bIsWriteCenterControl = NO;
    if ([[sIsWriteCenterControl uppercaseString] isEqualToString:@"TRUE"]) {
        bIsWriteCenterControl = YES;
    }
    obj.isWriteCenterControl = bIsWriteCenterControl;
    
    //是否设置 IP
    NSString *sIsSetIp = [configArr objectAtIndex:5];
    BOOL bIsSetIp = NO;
    if ([[sIsSetIp uppercaseString] isEqualToString:@"TRUE"]) {
        bIsSetIp = YES;
    }
    obj.isSetIp = bIsSetIp;
    
    //是否购买中控
    NSString *sIsBuyCenterControl = [configArr objectAtIndex:6];
    BOOL bIsBuyCenterControl = NO;
    if ([[sIsBuyCenterControl uppercaseString] isEqualToString:@"TRUE"]) {
        bIsBuyCenterControl = YES;
    }
    obj.isBuyCenterControl = bIsBuyCenterControl;
    
    return obj;
}

@end

/************************************************************************************/

@implementation SQLiteUtil

//获取数据库对象
+(FMDatabase *)getDB
{
    NSString *dbPath = [[DataUtil getDirectoriesInDomains] stringByAppendingPathComponent:DBNAME];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    return db;
}

//中控信息sql
+(NSString *)connectControlSql:(Control *)obj
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO CONTROL (\"Ip\", \"SendType\", \"Port\", \"Domain\", \"Url\", \"Updatever\") VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",obj.Ip, obj.SendType, obj.Port, obj.Domain, obj.Url, obj.Updatever];
    
    return sql;
}

//设备表sql拼接
+(NSString *)connectDeviceSql:(Device *)obj
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO DEVICE (\"DeviceId\" , \"DeviceName\" , \"Type\" , \"HouseId\" , \"LayerId\" , \"RoomId\") VALUES (\"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\")",obj.DeviceId, obj.DeviceName,obj.Type, obj.HouseId, obj.LayerId, obj.RoomId];
    return sql;
}

//命令表sql拼接
+(NSString *)connectOrderSql:(Order *)obj
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO ORDERS (\"OrderId\", \"OrderName\", \"Type\", \"SubType\" , \"OrderCmd\", \"Address\", \"StudyCmd\", \"HouseId\", \"LayerId\", \"RoomId\", \"DeviceId\") VALUES  (\"%@\", \"%@\", \"%@\", \"%@\" , \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",obj.OrderId, obj.OrderName,obj.Type, obj.SubType , obj.OrderCmd,obj.Address, obj.StudyCmd, obj.HouseId, obj.LayerId, obj.RoomId, obj.DeviceId];
    return sql;
}

//房间表sql拼接
+(NSString *)connectRoomSql:(Room *)obj
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO ROOM (\"RoomId\", \"RoomName\", \"HouseId\", \"LayerId\") VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",obj.RoomId,obj.RoomName,obj.HouseId, obj.LayerId];
    return sql;
}

//场景表sql拼接
+(NSString *)connectSenceSql:(Sence *)obj
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO SENCE (\"SenceId\" , \"SenceName\" , \"Macrocmd\" , \"Type\" , \"CmdList\" , \"HouseId\" , \"LayerId\" , \"RoomId\") VALUES (\"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\" , \"%@\")",obj.SenceId,obj.SenceName,obj.Macrocmd, obj.Type,obj.CmdList, obj.HouseId,obj.LayerId,obj.RoomId];
    return sql;
}

//获取设置当前默认楼层和房间号码
+(void)setDefaultLayerIdAndRoomId
{
    FMDatabase *db = [self getDB];
    
    NSString *sql = @"SELECT MIN(LAYERID) AS LayerId,ROOMID,HOUSEID FROM (SELECT RoomId,LayerId,HouseId FROM ROOM GROUP BY LAYERID ORDER BY LAYERID ASC)";
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]){
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[rs stringForColumn:@"LayerId"] forKey:@"LayerId"];
            [dic setObject:[rs stringForColumn:@"RoomId"] forKey:@"RoomId"];
            [dic setObject:[rs stringForColumn:@"HouseId"] forKey:@"HouseId"];
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:dic forKey:@"GLOBALATTR_UD"];
            [ud synchronize];
            
            break;
        }
        
        [rs close];
    }
    
    [db close];
}

//清除数据
+(void)clearData
{
    FMDatabase *db = [self getDB];
    
    [db open];
    
    [db executeUpdate:@"DELETE FROM CONTROL"];
    [db executeUpdate:@"DELETE FROM DEVICE"];
    [db executeUpdate:@"DELETE FROM ORDERS"];
    [db executeUpdate:@"DELETE FROM ROOM"];
    [db executeUpdate:@"DELETE FROM SENCE"];
    
    [db close];
}

//执行sql语句事物
+(BOOL)handleConfigToDataBase:(NSArray *)sqlArr
{
    FMDatabase *db = [self getDB];
    
    [db open];
    BOOL bResult = [self addToDataBase:db andSQL:sqlArr];
    [db close];
    
    return bResult;
}

//执行添加
+(BOOL)addToDataBase:(FMDatabase *)db andSQL:(NSArray *)sqlArr
{
    BOOL bResult = FALSE;
    
    [db beginTransaction];
    
    for (NSString *sql in sqlArr) {
        bResult = [db executeUpdate:sql];
    }
    
    [db commit];
    
    return bResult;
}

//获取场景列表
+(NSArray *)getSenceList:(NSString *)houseId
              andLayerId:(NSString *)layerId
              andRoomId:(NSString *)roomId
{
    NSMutableArray *senceArr = [NSMutableArray array];
    
    FMDatabase *db = [self getDB];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT S.*,I.NewType FROM SENCE S LEFT JOIN ICON I ON S.SENCEID=I.DEVICEID AND I.TYPE='macro' WHERE S.HOUSEID='%@' AND S.LAYERID='%@' AND S.ROOMID='%@'",houseId,layerId,roomId];

    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]){
            Sence *obj = [Sence setSenceId:[rs stringForColumn:@"SenceId"]
                              andSenceName:[rs stringForColumn:@"SenceName"]
                               andMacrocmd:[rs stringForColumn:@"Macrocmd"]
                                   andType:[rs stringForColumn:@"Type"]
                                andCmdList:[rs stringForColumn:@"CmdList"]
                                andHouseId:[rs stringForColumn:@"HouseId"]
                                andLayerId:[rs stringForColumn:@"LayerId"]
                                 andRoomId:[rs stringForColumn:@"RoomId"]
                               andIconType:[rs stringForColumn:@"NewType"]];
            [senceArr addObject:obj];
        }
        
        [rs close];
    }
    
    [db close];
    
    return senceArr;
}

//获取设备列表
+(NSArray *)getDeviceList:(NSString *)houseId
              andLayerId:(NSString *)layerId
               andRoomId:(NSString *)roomId
{
    NSMutableArray *deviceArr = [NSMutableArray array];
    
    FMDatabase *db = [self getDB];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT D.*,I.NewType FROM DEVICE D LEFT JOIN ICON I ON D.DEVICEID=I.DEVICEID AND I.TYPE !='%@' WHERE D.HOUSEID='%@' AND D.LAYERID='%@' AND D.ROOMID='%@'",MACRO,houseId,layerId,roomId];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]){
            Device *obj = [Device setDeviceId:[rs stringForColumn:@"DeviceId"]
                                andDeviceName:[rs stringForColumn:@"DeviceName"]
                                      andType:[rs stringForColumn:@"Type"]
                                   andHouseId:[rs stringForColumn:@"HouseId"]
                                   andLayerId:[rs stringForColumn:@"LayerId"]
                                    andRoomId:[rs stringForColumn:@"RoomId"]
                                  andIconType:[rs stringForColumn:@"NewType"]];
            [deviceArr addObject:obj];
        }
        
        [rs close];
    }
    
    [db close];
    
    return deviceArr;
}

//更新图标
+(BOOL)changeIcon:(NSString *)deviceId
          andType:(NSString *)type
       andNewType:(NSString *)newType
{
    BOOL bResult = FALSE;
    
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO ICON (DEVICEID,TYPE,NEWTYPE) VALUES ('%@','%@','%@')",deviceId,type,newType];
    
    FMDatabase *db = [self getDB];
    
    if ([db open]) {
        bResult = [db executeUpdate:sql];
    }
    
    [db close];
    
    return bResult;
}

//获取房间列表
+(NSArray *)getRoomList:(NSString *)houseId
             andLayerId:(NSString *)layerId
{
    NSMutableArray *roomArr = [NSMutableArray array];
    
    FMDatabase *db = [self getDB];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ROOM WHERE HOUSEID='%@' AND LAYERID='%@'",houseId,layerId];
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]){
            Room *obj = [Room setRoomId:[rs stringForColumn:@"RoomId"]
                            andRoomName:[rs stringForColumn:@"RoomName"]
                             andHouseId:[rs stringForColumn:@"HouseId"]
                             andLayerId:[rs stringForColumn:@"LayerId"]];
            [roomArr addObject:obj];
        }
        
        [rs close];
    }
    
    [db close];
    
    return roomArr;
}

@end
