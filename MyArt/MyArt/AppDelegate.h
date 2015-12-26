//
//  AppDelegate.h
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/5.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HTTPServer;
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    HTTPServer *httpServer;
}
@property (strong, nonatomic) UIWindow *window;


@end

