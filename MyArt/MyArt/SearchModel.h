//
//  SearchModel.h
//  MyMusicTest
//
//  Created by qqqssa on 15/12/14.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseModel.h"

@interface SearchModel : BaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pic_small;
@property (nonatomic, copy) NSString *song_id;
@property (nonatomic, copy) NSString *author;

+ (NSMutableArray*)parseRespondsData:(NSDictionary*)dictionary;

@end
