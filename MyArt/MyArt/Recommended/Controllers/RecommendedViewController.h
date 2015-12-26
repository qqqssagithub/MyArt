//
//  RecommendedViewController.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseViewController.h"

@interface RecommendedViewController : BaseViewController

@property (nonatomic, copy) void(^loadSong)(NSInteger, NSMutableArray *);

@end
