//
//  ListViewController.m
//  MyMusicTest
//
//  Created by qianfeng0 on 15/12/8.
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
@end

@implementation ListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - 64 - 49);
    self.tableView.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songData = [[NSMutableArray alloc] init];
    self.songList = [[NSMutableArray alloc] init];
    [self cunstomUI];
    [self fetchData];

    self.pic = @[@"新歌.jpg", @"热歌.jpg", @"欧美.jpg", @"king.jpg", @"原创.jpg", @"华语.jpg", @"金典.jpg", @"网络.jpg", @"影视.jpg", @"对唱.jpg", @"bi.jpg", @"摇滚.jpg", @"ktv.jpg", @"cc.jpg",];
    
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

- (void)cunstomUI{
    [self.tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil] forCellReuseIdentifier:@"list"];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void)fetchData{
    [[NetDataEngine sharedInstance] GET:URL_LIST success:^(id responsData) {
        self.dataSource = [ListModel parseRespondsData:responsData];
        [self.tableView reloadData];
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
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
}

- (void)fenchSongData:(NSInteger)index{//获取列表
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
    static int index = 0;
    for (int i = 0; i < 30 && i < self.songData.count; i++) {
        index++;
        [[NetDataEngine sharedInstance] GET:[NSString stringWithFormat:SONG_URL, self.songData[i], SONG_URL_X] success:^(id responsData) {
            SongModel *oneSong = [SongModel parseRespondsData:responsData];
            [self.songList addObject:oneSong];
            if (self.songList.count == 30 || self.songList.count == self.songData.count) {
                self.loadMusic(self.songList);
                [KVNProgress dismiss];
            }
            if (index == self.songData.count && index > self.songList.count) {
                NSLog(@"歌曲列表刷新失败,请重新刷新");
            }
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
