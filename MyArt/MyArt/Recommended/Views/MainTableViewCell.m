//
//  MainTableViewCell.m
//  MyMusicTest
//
//  Created by qqqssa on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "MainTableViewCell.h"



@implementation MainTableViewCell


- (void)updateWithModel:(SongModel *)model{
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic_small] placeholderImage:[UIImage imageNamed:@"bg"]];
    self.title.text = model.title;
    self.author.text = model.author;
}


- (void)updateWithSearchModel:(SearchModel *)model{
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic_small] placeholderImage:[UIImage imageNamed:@"bg"]];
    self.title.text = model.title;
    self.author.text = model.author;
}

- (void)updateWithSongDetail:(SongDetail *)oneSongDetail{
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:oneSongDetail.pic_small] placeholderImage:[UIImage imageNamed:@"bg"]];
    self.title.text = oneSongDetail.title;
    self.author.text = oneSongDetail.author;
}

//- (void)updateWithBaseModel:(BaseModel *)baseModel {
//    [self.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic_small] placeholderImage:[UIImage imageNamed:@"bg"]];
//    self.title.text = model.title;
//    self.author.text = model.author;
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
