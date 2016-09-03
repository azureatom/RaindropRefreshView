//
//  RaindropRefreshHeader.m
//  GuPiaoTaoLi
//
//  Created by lei xue on 16/9/2.
//  Copyright © 2016年 userstar. All rights reserved.
//

#import "RaindropRefreshHeader.h"
#import "RaindropRefreshView.h"

@interface RaindropRefreshHeader()
@property(strong, nonatomic) RaindropRefreshView *raindropRefreshView;
@end

@implementation RaindropRefreshHeader
@synthesize raindropRefreshView;

#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare{
    [super prepare];
    self.automaticallyChangeAlpha = YES;
    
    raindropRefreshView = [[RaindropRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    raindropRefreshView.shapeColor = [UIColor redColor];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.color = raindropRefreshView.shapeColor;
    [activityIndicatorView startAnimating];//一直旋转，只会设置alpha为0或1.
    raindropRefreshView.refreshingIndicator = activityIndicatorView;
    [raindropRefreshView setupControl];
    [self addSubview:raindropRefreshView];
    
    self.mj_h = raindropRefreshView.pullHeightRequired;
}

//#pragma mark 在这里设置子控件的位置和尺寸
//- (void)placeSubviews{
//    [super placeSubviews];
//}
//
//#pragma mark 监听scrollView的contentOffset改变
//- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
//    [super scrollViewContentOffsetDidChange:change];
//}
//
//#pragma mark 监听scrollView的contentSize改变
//- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
//    [super scrollViewContentSizeDidChange:change];
//}
//
//#pragma mark 监听scrollView的拖拽状态改变
//- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
//    [super scrollViewPanStateDidChange:change];
//}

- (void)setState:(MJRefreshState)state{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [raindropRefreshView endRefreshing];
            break;
        case MJRefreshStatePulling:
            break;
        case MJRefreshStateRefreshing:
            raindropRefreshView.frame = CGRectMake(0, 0, self.bounds.size.width, self.mj_h);
            [raindropRefreshView beginRefreshing:NO];
            break;
        default:
            break;
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent{
    [super setPullingPercent:pullingPercent];
    //pullingPercent取值[0, +∞)，也即可能大于1，此时raindropRefreshView总是显示在header的最顶端不动，但是height会变大
    raindropRefreshView.frame = CGRectMake(0, self.mj_h - self.mj_h * pullingPercent, self.bounds.size.width, self.mj_h * pullingPercent);
}

@end
