//
//  NetDataEngine.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/7.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "NetDataEngine.h"


@interface NetDataEngine ()

//网络请求类
@property (nonatomic) AFHTTPSessionManager * httpManager;

@end

@implementation NetDataEngine

+ (instancetype)sharedInstance{
    static NetDataEngine *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[NetDataEngine alloc]init];
    });
    return s_instance;
}

- (id)init{
    if (self = [super init]) {
        _httpManager = [[AFHTTPSessionManager alloc]init];
    }
    return self;
}

- (void)GET:(NSString*)url success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock{
    [_httpManager GET:url parameters:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

@end

