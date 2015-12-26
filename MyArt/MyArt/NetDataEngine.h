//
//  NetDataEngine.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/7.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <Foundation/Foundation.h>

//定义block类型，用于网络请求结果的传递
typedef void(^SuccessBlockType) (id responsData);
typedef void(^FailedBlockType) (NSError *error);

@interface NetDataEngine : NSObject

//单例
+ (instancetype)sharedInstance;

- (void)GET:(NSString*)url success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;

@end
