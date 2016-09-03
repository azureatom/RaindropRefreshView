//
//  RaindropRefreshView.h
//  RaindropRefreshView
//
//  Created by lei xue on 16/9/2.
//  Copyright © 2016年 userstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RaindropRefreshView:UIView
@property (strong, nonatomic) UIColor *shapeColor;//灰色[UIColor colorWithRed:155.0 / 255.0 green:162.0 / 255.0 blue:172.0 / 255.0 alpha:1.0]
@property (strong, nonatomic) UIView *refreshingIndicator;//如UIActivityIndicatorView等，可以设置activityIndicatorViewStyle和color样式
@property (assign, nonatomic, readonly) CGFloat pullHeightRequired;//下拉动画完全展开需要的高度，不包括刷新动画

/**
 *  initWithFrame、设置属性之后，再调用该方法生成控件
 */
- (void)setupControl;
- (void)beginRefreshing:(BOOL)animated;
- (void)endRefreshing;
@end
