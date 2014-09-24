//
//  Model.h
//  QLink
//
//  Created by 尤日华 on 14-9-21.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <Foundation/Foundation.h>

/********************************************************************/

//存储全局变量
@interface GlobalAttr : NSObject

@property(nonatomic,strong) NSString *LayerId;
@property(nonatomic,strong) NSString *RoomId;
@property(nonatomic,strong) NSString *HouseId;

+(GlobalAttr *)shareInstance;

//更新房间号
+(void)setGlobalAttr:(NSString *)roomId;

@end

/********************************************************************/

@interface Control : NSObject

@property(nonatomic,strong) NSString *Ip;
@property(nonatomic,strong) NSString *SendType;
@property(nonatomic,strong) NSString *Port;
@property(nonatomic,strong) NSString *Domain;
@property(nonatomic,strong) NSString *Url;
@property(nonatomic,strong) NSString *Updatever;

+(Control *)setIp:(NSString *)ip
      andSendType:(NSString *)sendType
          andPort:(NSString *)port
        andDomain:(NSString *)domain
           andUrl:(NSString *)url
     andUpdatever:(NSString *)updatever;

@end

/********************************************************************/

@interface Device : NSObject

@property(nonatomic,strong) NSString *DeviceId;
@property(nonatomic,strong) NSString *DeviceName;
@property(nonatomic,strong) NSString *Type;
@property(nonatomic,strong) NSString *HouseId;
@property(nonatomic,strong) NSString *LayerId;
@property(nonatomic,strong) NSString *RoomId;
@property(nonatomic,strong) NSString *IconType;

+(Device *)setDeviceId:(NSString *)deviceId
         andDeviceName:(NSString *)deviceName
               andType:(NSString *)type
            andHouseId:(NSString *)houseId
            andLayerId:(NSString *)layerId
             andRoomId:(NSString *)roomId
           andIconType:(NSString *)iconType;

@end


/********************************************************************/

@interface Order : NSObject

@property(nonatomic,strong) NSString *OrderId;
@property(nonatomic,strong) NSString *OrderName;
@property(nonatomic,strong) NSString *Type;
@property(nonatomic,strong) NSString *SubType;
@property(nonatomic,strong) NSString *OrderCmd;
@property(nonatomic,strong) NSString *Address;
@property(nonatomic,strong) NSString *StudyCmd;
@property(nonatomic,strong) NSString *HouseId;
@property(nonatomic,strong) NSString *LayerId;
@property(nonatomic,strong) NSString *RoomId;
@property(nonatomic,strong) NSString *DeviceId;

+(Order *)setOrderId:(NSString *)orderId
        andOrderName:(NSString *)orderName
             andType:(NSString *)type
          andSubType:(NSString *)subType
         andOrderCmd:(NSString *)orderCmd
          andAddress:(NSString *)address
         andStudyCmd:(NSString *)studyCmd
          andHouseId:(NSString *)houseId
          andLayerId:(NSString *)layerId
           andRoomId:(NSString *)roomId
         andDeviceId:(NSString *)deviceId;

@end


/********************************************************************/

@interface Room : NSObject

@property(nonatomic,strong) NSString *RoomId;
@property(nonatomic,strong) NSString *RoomName;
@property(nonatomic,strong) NSString *HouseId;
@property(nonatomic,strong) NSString *LayerId;

+(Room *)setRoomId:(NSString *)roomId
       andRoomName:(NSString *)roomName
        andHouseId:(NSString *)houseId
        andLayerId:(NSString *)layerId;

@end


/********************************************************************/

@interface Sence : NSObject

@property(nonatomic,strong) NSString *SenceId;
@property(nonatomic,strong) NSString *SenceName;
@property(nonatomic,strong) NSString *Macrocmd;
@property(nonatomic,strong) NSString *Type;
@property(nonatomic,strong) NSString *CmdList;
@property(nonatomic,strong) NSString *HouseId;
@property(nonatomic,strong) NSString *LayerId;
@property(nonatomic,strong) NSString *RoomId;
@property(nonatomic,strong) NSString *IconType;


+(Sence *)setSenceId:(NSString *)senceId
        andSenceName:(NSString *)senceName
         andMacrocmd:(NSString *)macrocmd
             andType:(NSString *)type
          andCmdList:(NSString *)cmdList
          andHouseId:(NSString *)houseId
          andLayerId:(NSString *)layerId
           andRoomId:(NSString *)roomId
         andIconType:(NSString *)iconType;

@end
