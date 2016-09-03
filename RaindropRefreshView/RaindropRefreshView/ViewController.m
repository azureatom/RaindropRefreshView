//
//  ViewController.m
//  RaindropRefreshView
//
//  Created by lei xue on 16/9/3.
//  Copyright © 2016年 userstar. All rights reserved.
//

#import "ViewController.h"
#import "RaindropRefreshView.h"
#import "RaindropRefreshHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scrollView];
    for (int i = 0; i < 3; ++i) {
        RaindropRefreshView *raindropRefreshView = [[RaindropRefreshView alloc] initWithFrame:CGRectMake(50 * i, 100, 50, 30 * (i + 1))];
        raindropRefreshView.refreshingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [raindropRefreshView setupControl];
        [scrollView addSubview:raindropRefreshView];
    }
    
    RaindropRefreshHeader *header = [RaindropRefreshHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scrollView.mj_header endRefreshing];
        });
    }];
    scrollView.mj_header = header;
    //自动刷新
    [scrollView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
