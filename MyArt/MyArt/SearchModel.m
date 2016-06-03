//
//  SearchModel.m
//  MyMusicTest
//
//  Created by qqqssa on 15/12/14.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary{
    NSMutableArray *mainArray = [NSMutableArray array];
    NSArray *dataArray0 = dictionary[@"result"][@"song_info"][@"song_list"];
    NSArray *dataArray1 = dictionary[@"result"][@"album_info"][@"album_list"];
    for (NSInteger index = 0; index < dataArray0.count; index ++) {
        SearchModel *model = [[SearchModel alloc] init];
        model.title = dataArray0[index][@"title"];
        if (index <dataArray1.count) {
            model.pic_small = dataArray1[index][@"pic_small"];
        }
        model.song_id = dataArray0[index][@"song_id"];
        model.author = dataArray0[index][@"author"];
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
