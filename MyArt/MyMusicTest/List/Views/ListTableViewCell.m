//
//  ListTableViewCell.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/13.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "ListTableViewCell.h"


@implementation ListTableViewCell


- (void)updateWith:(ListModel *)model path:(NSString *)picPath{
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:model.pic_s192] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.imgV.image = [UIImage imageNamed:picPath];
    }];
    self.title.text = model.name;
    self.one.text = [NSString stringWithFormat:@"1.%@-%@", [(model.content)[0] valueForKey:@"title"], [(model.content)[0] valueForKey:@"author"]];
    self.tow.text = [NSString stringWithFormat:@"2.%@-%@", [(model.content)[1] valueForKey:@"title"], [(model.content)[1] valueForKey:@"author"]];
    self.three.text = [NSString stringWithFormat:@"3.%@-%@", [(model.content)[2] valueForKey:@"title"], [(model.content)[2] valueForKey:@"author"]];
    [UIView animateWithDuration:0.3 animations:^{
        self.imgV.center = CGPointMake(self.imgV.center.x - 300, self.imgV.center.y);
        self.title.center = CGPointMake(self.title.center.x - 300, self.title.center.y);
        self.one.center = CGPointMake(self.one.center.x - 300, self.one.center.y);
        self.tow.center = CGPointMake(self.tow.center.x - 300, self.tow.center.y);
        self.three.center = CGPointMake(self.three.center.x - 300, self.three.center.y);
    }];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
