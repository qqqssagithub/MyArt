//
//  ListViewController.m
//  MyMusicTest
//
//  Created by qqqssa on 15/12/8.
//  Copyright © 2015年 陈少文. All rights reserved.
//

#import "ListViewController.h"
#import "ListModel.h"
#import "ListTableViewCell.h"

#define URL_LIST @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.billboard.billCategory&format=json&from=ios&kflag=1&version=5.5.1&from=ios&channel=appstore"
#define URL_songData @"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.billboard.billList&type=%@&format=json&offset=0&size=100&from=ios&fields=title,song_id,author,resource_type,havehigh,is_new,has_mv_mobile,album_title,ting_uid,album_id,charge,all_rate&version=5.5.1&from=ios&channel=appstore"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *songList;
@property (nonatomic) NSMutableArray *songData;

@property (nonatomic) NSArray *pic;


@property (nonatomic) NetworkRefreshFailedView *networkRefreshFailedView;
@end

@implementation ListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 - 49);
    self.tableView.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self addBackLabel];

    self.songData = [[NSMutableArray alloc] init];
    self.songList = [[NSMutableArray alloc] init];
    [self cunstomUI];
    [self fetchData];

    self.pic = @[@"新歌.jpg", @"热歌.jpg", @"欧美.jpg", @"king.jpg", @"原创.jpg", @"华语.jpg", @"金典.jpg", @"网络.jpg", @"影视.jpg", @"对唱.jpg", @"bi.jpg", @"摇滚.jpg", @"ktv.jpg", @"cc.jpg",];

    [KVNProgress showWithStatus:@"榜单初始化加载中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataSource.count == 0) {
            [KVNProgress dismiss];
            [self addTempView];
        }
    });
}

- (void)addBackLabel {
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, SCREEN_WIDTH, 48)];
    backLabel.numberOfLines = 3;
    backLabel.font = [UIFont boldSystemFontOfSize:13];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.text = @"APP所有音乐资源均取自百度音乐\n仅作为分享用\n不用于任何商业目的";
    [self.view addSubview:backLabel];
    
    UILabel *backLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT -2 -48 -49 -64, SCREEN_WIDTH, 48)];
    backLabel0.numberOfLines = 3;
    backLabel0.font = [UIFont boldSystemFontOfSize:13];
    backLabel0.textColor = [UIColor whiteColor];
    backLabel0.backgroundColor = [UIColor clearColor];
    backLabel0.textAlignment = NSTextAlignmentCenter;
    backLabel0.text = @"此项目为开源项目\n源代码由\"qqqssa\"提供\nhttps://github.com/qqqssagithub/MyArt.git";
    [self.view addSubview:backLabel0];
    
}

- (void)addTempView{
    if (_networkRefreshFailedView == nil) {
        _networkRefreshFailedView = [[NetworkRefreshFailedView alloc] init];
        UITapGestureRecognizer *netViewtapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(netViewtapGR:)];
        [_networkRefreshFailedView addGestureRecognizer:netViewtapGR];
        [self.view addSubview:_networkRefreshFailedView];
    }
}


-(void)netViewtapGR:(UITapGestureRecognizer *)tapGR{
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == NotReachable) {
        [KVNProgress dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (_networkRefreshFailedView != nil) {
        [_networkRefreshFailedView removeFromSuperview];
        _networkRefreshFailedView = nil;
    }
    if (self.dataSource.count == 0) {
        [self fetchData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataSource.count == 0) {
            [KVNProgress dismiss];
            [self addTempView];
        }
    });
}

#pragma mark - UI
- (void)cunstomUI{
    [self.tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil] forCellReuseIdentifier:@"list"];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void)fetchData{
    [[NetDataEngine sharedInstance] GET:URL_LIST success:^(id responsData) {
        [KVNProgress dismiss];
        self.dataSource = [ListModel parseRespondsData:responsData];
        [self.tableView reloadData];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.tableView.backgroundColor = [UIColor clearColor];
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ListModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell updateWith:model path:self.pic[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [KVNProgress showWithStatus:@"榜单加载中..."];
    [self.songData removeAllObjects];
    [self.songList removeAllObjects];
    [self fenchSongData:indexPath.row];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KVNProgress dismiss];
    });
}

- (void)isNetworking{
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == NotReachable) {
        [KVNProgress dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

- (void)fenchSongData:(NSInteger)index{//获取列表
    [self isNetworking];
    [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:URL_songData, ((ListModel *)self.dataSource[index]).type] success:^(id responsData) {
        NSArray *arr = responsData[@"song_list"];
        for (NSDictionary *dic in arr) {
            NSString *song_id = dic[@"song_id"];
            [self.songData addObject:song_id];
        }
        [self loadSongList];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)loadSongList{
    [self isNetworking];
    static int index = 0;
    for (int i = 0; i < 30 && i < self.songData.count; i++) {
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, self.songData[i], SONG_URL_X] success:^(id responsData) {
            index++;
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            if (oneSong.songFiles.count != 0) {
                [self.songList addObject:oneSong];
            }
            if (index == 30 || self.songList.count == self.songData.count) {
                self.loadMusic(self.songList);
                index = 0;
                [KVNProgress dismiss];
            }
//            if (index == self.songData.count && index > self.songList.count) {
//                NSLog(@"歌曲列表刷新失败,请重新刷新");
//            }
        } failed:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
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
