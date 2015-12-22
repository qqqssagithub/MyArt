//
//  BaseViewController.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/7.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, copy) void(^loadMusic)(NSMutableArray *);

@end
