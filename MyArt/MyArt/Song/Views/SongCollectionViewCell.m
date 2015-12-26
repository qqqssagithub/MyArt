//
//  SongCollectionViewCell.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/13.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "SongCollectionViewCell.h"

@implementation SongCollectionViewCell

- (void)updateWithModel:(SongsModel *)model{
    self.title.text = model.title;
    self.listenum.text = model.listenum;
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic_300]];
}

- (void)awakeFromNib {
    // Initialization code
}

@end
