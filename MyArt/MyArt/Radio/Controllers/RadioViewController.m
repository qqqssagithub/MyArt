//
//  RadioViewController.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "RadioViewController.h"
#import "RadioModel.h"


#define URL_CH @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.radio.getChannelSong&channelid=%@&channelname=%@&pn=0&rn=59&format=json&from=ios&baiduid=1bb92ffcf38c17a7d8a3b3e75361f0a85c8b7054&version=5.5.1&from=ios&channel=appstore"

@interface RadioViewController () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, copy) NSArray *radioNames;
@property (nonatomic, copy) NSArray *radioPic;
@property (nonatomic, copy) NSArray *tag;
@property (nonatomic) NSMutableArray *jingdianlaoge;
@property (nonatomic) NSMutableArray *rege;
@property (nonatomic) NSMutableArray *chengmingqu;
@property (nonatomic) NSMutableArray *oumei;
@property (nonatomic) NSMutableArray *wangluo;
@property (nonatomic) NSMutableArray *suibiantingting;
@property (nonatomic) NSMutableArray *dianyingyuansheng;

@property (nonatomic) NSMutableArray *songList;

@property (weak, nonatomic) IBOutlet UIImageView *imgV;

@property (nonatomic) UIAlertController *alertController;

@property (nonatomic) UILabel *label;

@property (nonatomic) NSString *tempRadioName;
@property (nonatomic) BOOL reload;
@end


@implementation RadioViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.imgV.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 -49);
    self.carousel.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 -49);
    [KVNProgress showWithParameters:@{KVNProgressViewParameterStatus: @"电台加载上线中,请稍等...", KVNProgressViewParameterFullScreen: @(YES)}];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.radioNames = @[@"经典老歌", @"劲爆热歌", @"成名金曲", @"流行欧美", @"网络歌曲", @"随便听听", @"电影原声"];
    self.radioPic = @[@"jd", @"jg", @"cmq", @"om", @"wl", @"sbtt", @"dy"];
    self.tag = @[@(3000), @(3001), @(3002), @(3003), @(3004), @(3005), @(3006)];
    self.carousel.type = iCarouselTypeInvertedTimeMachine;
    self.carousel.pagingEnabled = YES;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    self.jingdianlaoge = [NSMutableArray array];
    self.rege = [NSMutableArray array];
    self.chengmingqu = [NSMutableArray array];
    self.oumei = [NSMutableArray array];
    self.wangluo = [NSMutableArray array];
    self.suibiantingting = [NSMutableArray array];
    self.dianyingyuansheng = [NSMutableArray array];
    
    self.songList = [[NSMutableArray alloc] init];
    
    [self loadRadio];
    
    _alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"此电台频道初始化失败,请重新加载" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reloadRadio:self.tempRadioName];
    }];
    [_alertController addAction:okAction];
    
    
    [self setupBaseKVNProgressUI];
}

#pragma mark - UI

- (void)setupBaseKVNProgressUI
{
    // See the documentation of all appearance propoerties
    [KVNProgress appearance].statusColor = [UIColor darkGrayColor];
    [KVNProgress appearance].statusFont = [UIFont systemFontOfSize:17.0f];
    [KVNProgress appearance].circleStrokeForegroundColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
    [KVNProgress appearance].backgroundFillColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
    [KVNProgress appearance].backgroundTintColor = [UIColor whiteColor];
    [KVNProgress appearance].successColor = [UIColor darkGrayColor];
    [KVNProgress appearance].errorColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleSize = 75.0f;
    [KVNProgress appearance].lineWidth = 2.0f;
}


- (void)loadRadio{
    [self fetchData:[self getdate] ch:@"public_shiguang_jingdianlaoge" data:self.jingdianlaoge];
    [self fetchData:[self getdate] ch:@"public_tuijian_rege" data:self.rege];
    [self fetchData:[self getdate] ch:@"public_tuijian_chengmingqu" data:self.chengmingqu];
    [self fetchData:[self getdate] ch:@"public_yuzhong_oumei" data:self.oumei];
    [self fetchData:[self getdate] ch:@"public_tuijian_wangluo" data:self.wangluo];
    [self fetchData:[self getdate] ch:@"public_tuijian_suibiantingting" data:self.suibiantingting];
    [self fetchData:[self getdate] ch:@"public_fengge_dianyingyuansheng" data:self.dianyingyuansheng];
}

- (void)reloadRadio:(NSString *)radioName{
    [KVNProgress showWithStatus:@"电台重载中..."];
    self.reload = YES;
    [self fetchData:[self getdate] ch:radioName data:self.jingdianlaoge];
}

#pragma mark - iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 7;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.7, SCREEN_WIDTH * 0.7)];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGR:)];
        [imageView addGestureRecognizer:tapGR];
        
        
        imageView.tag = [self.tag[index] integerValue];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
        self.label.text = self.radioNames[index];
        self.label.textColor = [UIColor purpleColor];
        [imageView addSubview:self.label];

        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.2f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.radioPic[index] ofType:@"jpg"];
    //set image
    ((FXImageView *)view).image = [UIImage imageWithContentsOfFile:path];
    
    return view;

}

-(void)tapGR:(UITapGestureRecognizer *)tapGR{
    NSInteger index = tapGR.view.tag;
    switch (index) {
        case 3000:
            if (self.jingdianlaoge.count == 0) {
                self.tempRadioName = @"public_shiguang_jingdianlaoge";
                [self presentViewController:_alertController animated:YES completion:nil];
                return;
            }
            self.openPlayViewBlock(self.jingdianlaoge);
            break;
        case 3001:
            if (self.rege.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_rege";
                return;
            }
            self.openPlayViewBlock(self.rege);
            //public_tuijian_rege
            break;
        case 3002:
            if (self.chengmingqu.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_chengmingqu";
                return;
            }
            self.openPlayViewBlock(self.chengmingqu);
            //public_tuijian_chengmingqu
            break;
        case 3003:
            if (self.oumei.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_yuzhong_oumei";
                return;
            }
            self.openPlayViewBlock(self.oumei);
            //public_yuzhong_oumei
            break;
        case 3004:
            if (self.wangluo.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_wangluo";
                return;
            }
            self.openPlayViewBlock(self.wangluo);
            //public_tuijian_wangluo
            break;
        case 3005:
            if (self.suibiantingting.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_tuijian_suibiantingting";
                return;
            }
            self.openPlayViewBlock(self.suibiantingting);
            //public_tuijian_suibiantingting
            break;
        case 3006:
            if (self.dianyingyuansheng.count == 0) {
                [self presentViewController:_alertController animated:YES completion:nil];
                self.tempRadioName = @"public_fengge_dianyingyuansheng";
                return;
            }
            self.openPlayViewBlock(self.dianyingyuansheng);
            //public_fengge_dianyingyuansheng
            break;
 
        default:
            break;
    }
}

- (void)loadSongList:(NSMutableArray *)data songData:songList{
    [self.songList removeAllObjects];
    for (int i = 0; i < data.count - 2; i++) {
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, data[i], SONG_URL_X] success:^(id responsData) {
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            [songList addObject:oneSong];
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}


- (NSString *)getdate{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH";
    NSString *formatDate = [format stringFromDate:[NSDate date]];
    NSLog(@"%@", formatDate);
    return formatDate;
}

- (void)fetchData:(NSString *)page ch:(NSString *)ch data:(NSMutableArray *)songList{
    static int i = 0; static int j = 0; j = 0;
    [[NetDataEngine sharedInstance] GET:[[NSString stringWithFormat:URL_CH, page, ch] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] success:^(id responsData) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic in responsData[@"result"][@"songlist"]) {
            NSString *song_id = dic[@"songid"];
            if (song_id == nil) {
                continue;
            }
            [arr addObject:song_id];
        }
        i++; j++;
        [self loadSongList:arr songData:songList];
        if (i == 7) {
            [KVNProgress dismiss];
        } else if (j == 1 && self.reload) {
            [KVNProgress dismiss];
            self.reload = NO;
        }
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
