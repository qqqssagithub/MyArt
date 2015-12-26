//
//  RecommendedModel.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "RecommendedModel.h"

@implementation RecommendedModel

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary{
    NSMutableArray *mainArray = [NSMutableArray array];
    NSArray *dataArray = dictionary[@"content"];
    for (NSDictionary *dic in dataArray) {
        RecommendedModel *model = [[RecommendedModel alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        [mainArray addObject:model];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:dictionary[@"title"] forKey:@"title"];
    [dic setValue:dictionary[@"pic_w700"] forKey:@"pic_w700"];
    [dic setValue:dictionary[@"tag"] forKey:@"tag"];
    [dic setValue:dictionary[@"desc"] forKey:@"desc"];
    [mainArray addObject:dic];
    return mainArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
