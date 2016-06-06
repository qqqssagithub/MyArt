//
//  UISearchBar+additional.m
//  MyArt
//
//  Created by 007 on 16/6/4.
//  Copyright © 2016年 陈少文. All rights reserved.
//

#import "UISearchBar+additional.h"

@implementation UISearchBar (additional)

- (void)additional {
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:DEFAULTCOLOR];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    self.inputAccessoryView = toolbar;
}

- (void)onKeyBoardDown:(id)sender {
    [self resignFirstResponder];
}

@end
