//
//  RadioViewController.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "BaseViewController.h"

@interface RadioViewController : BaseViewController

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (nonatomic, copy) void(^openPlayViewBlock)(NSMutableArray *);

@end
