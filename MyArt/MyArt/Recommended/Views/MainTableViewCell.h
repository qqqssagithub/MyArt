//
//  MainTableViewCell.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongModel.h"
#import "SearchModel.h"
#import "SongDetail.h"



@interface MainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;

- (void)updateWithModel:(SongModel *)model;

- (void)updateWithSearchModel:(SearchModel *)model;

- (void)updateWithSongDetail:(SongDetail *)oneSongDetail;

@end
