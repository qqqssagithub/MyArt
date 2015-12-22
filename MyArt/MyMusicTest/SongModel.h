//
//  SongModel.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/10.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseModel.h"

@interface SongModel : BaseModel

@property (nonatomic ,copy) NSString *song_id;
@property (nonatomic, copy) NSString *pic_small;//cell
@property (nonatomic, copy) NSString *pic_radio;//主视图
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *album_title;
@property (nonatomic, copy) NSString *lrclink;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSMutableArray *songFiles;

+ (SongModel *)parseRespondsData:(NSDictionary*)dictionary;

@end
