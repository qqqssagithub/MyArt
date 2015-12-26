//
//  RadioModel.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/12.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseModel.h"

@interface RadioModel : BaseModel

@property (nonatomic, copy) NSString *songid;

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary;

@end
