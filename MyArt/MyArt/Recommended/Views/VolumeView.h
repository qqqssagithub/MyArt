//
//  VolumeView.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/20.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolumeView : UIView

@property (nonatomic, copy) void(^volume)(float value);

@end
