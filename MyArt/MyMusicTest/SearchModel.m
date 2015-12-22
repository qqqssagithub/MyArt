//
//  SearchModel.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/14.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary{
    NSMutableArray *mainArray = [NSMutableArray array];
    NSArray *dataArray = dictionary[@"result"][@"song_info"][@"song_list"];
    for (NSDictionary *dic in dataArray) {
        SearchModel *model = [[SearchModel alloc] init];
        [model setValuesForKeysWithDictionary:dic];
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
