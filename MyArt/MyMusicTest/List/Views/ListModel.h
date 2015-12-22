//
//  ListModel.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/13.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseModel.h"

@interface ListModel : BaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pic_s192;
@property (nonatomic, copy) NSArray *content;
@property (nonatomic, copy) NSString *type;

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary;

@end
