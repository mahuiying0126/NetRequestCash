//
//  ViewController.m
//  NetworkRequestTest
//
//  Created by yizhilu on 2017/7/21.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/** *数据列表*/
@property (nonatomic, strong) UITableView *tableViewM;
/** *当前页*/
@property (nonatomic, assign) NSInteger currentPage;
/** *总页*/
@property (nonatomic, assign) NSInteger totlePage;

/** *数据*/
@property (nonatomic, strong) NSMutableArray *dataArray;

/** *是否刷新*/
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.currentPage = 1;
    self.tableViewM = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    [self.view addSubview:self.tableViewM];
    self.tableViewM.delegate = self;
    self.tableViewM.dataSource = self;
    self.tableViewM.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self addTableViewRefresh];
    [self loadDataforUrl];
}

-(void)addTableViewRefresh{
    self.tableViewM.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.tableViewM.mj_header beginRefreshing];
        self.currentPage = 1;
        self.isRefresh = YES;
        [self loadDataforUrl];
        [self.tableViewM.mj_header endRefreshing];
    }];
    
    self.tableViewM.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self.tableViewM.mj_footer beginRefreshing];
        self.currentPage ++;
        if (self.currentPage < self.totlePage) {
            self.isRefresh = NO;
            [self loadDataforUrl];
        }
        [self.tableViewM.mj_footer endRefreshing];
    }];
}

-(void)loadDataforUrl{
    
    MNetSetting *seting = [[MNetSetting alloc]init];
    NSString *hostUrl =  @"请求地址";
    NSDictionary *paramet = @{};//参数
    seting.jsonValidator = @{};//json格式验证
    seting.cashSeting = MCacheSave;
    seting.isRefresh = self.isRefresh;
    __weak typeof(self) weakSelf = self;
    [seting requestDataFromHostURL:hostUrl andParameter:paramet success:^(id responseData) {
        //数据处理
        
        [weakSelf.tableViewM reloadData];
    } failure:^(NSError *error) {
        
    } netSeting:seting];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *cellData = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",cellData[@"shortContent"]];
    
   
    return cell;
    
}


-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
