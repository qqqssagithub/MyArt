//
//  SongModel.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/10.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "SongModel.h"

@implementation SongModel

+ (SongModel *)parseRespondsData:(NSDictionary*)dictionary{
    SongModel *model = [[SongModel alloc] init];
    [model setValuesForKeysWithDictionary:dictionary[@"songinfo"]];
    
    NSArray *tempSongUrlArr = ((NSDictionary *)dictionary[@"songurl"])[@"url"];
    NSMutableArray *songFiles = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in tempSongUrlArr) {
        [songFiles addObject:dic[@"file_link"]];
    }
    model.songFiles = songFiles;
    return model;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
