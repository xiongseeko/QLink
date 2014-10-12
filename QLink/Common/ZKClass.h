//
//  ZKClass.h
//  QLink
//
//  Created by 尤日华 on 14-10-4.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZKClassDelegate <NSObject>

-(void)successZKOper;

@end

@interface ZKClass : NSObject
//{
//    NSMutableData *responseData_;
//}

@property(nonatomic,assign) id<ZKClassDelegate>delegate;
@property(nonatomic,assign) NSOperationQueue *queue;
//@property(nonatomic,assign) int iRetryCount;//连接次数


-(id)init;
-(void)initZhongKong;

@end
