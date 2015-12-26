//
//  ListTableViewCell.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/13.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListModel.h"

@interface ListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *one;
@property (weak, nonatomic) IBOutlet UILabel *tow;
@property (weak, nonatomic) IBOutlet UILabel *three;

- (void)updateWith:(ListModel *)model path:(NSString *)picPath;

@end
