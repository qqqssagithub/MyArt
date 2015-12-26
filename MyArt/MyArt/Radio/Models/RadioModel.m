//
//  RadioModel.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/12.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "RadioModel.h"

@implementation RadioModel


+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary{
    NSMutableArray *mainArray = [NSMutableArray array];
    NSDictionary *dic = dictionary[@"result"];
    NSArray *dataArray = dic[@"songlist"];
    for (int i = 0; i < dataArray.count; i++) {
        RadioModel *model = [[RadioModel alloc] init];
        model.songid = ((NSDictionary *)(dataArray[i]))[@"songid"];
        [mainArray addObject:model];
    }
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
