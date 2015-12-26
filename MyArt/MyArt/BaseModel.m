//
//  BaseModel.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/7.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //NSLog(@"捕获到未定义的key=[%@]",key);
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
