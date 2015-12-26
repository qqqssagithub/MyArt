//
//  SongCollectionViewCell.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/13.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongsModel.h"

@interface SongCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *listenum;
@property (weak, nonatomic) IBOutlet UILabel *title;

- (void)updateWithModel:(SongsModel *)model;

@end
