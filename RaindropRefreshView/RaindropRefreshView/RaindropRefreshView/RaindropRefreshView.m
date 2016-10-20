//
//  RaindropRefreshView.m
//  RaindropRefreshView
//
//  Created by lei xue on 16/9/2.
//  Copyright © 2016年 userstar. All rights reserved.
//

#import "RaindropRefreshView.h"
static const CGFloat kMinTopPadding    = 4.0f;
static const CGFloat kMaxTopPadding    = 7.0f;
static const CGFloat kMinTopRadius     = 10.0f;
static const CGFloat kMaxTopRadius     = 13.0f;
static const CGFloat kMinBottomRadius  = 2.5f;
static const CGFloat kMaxBottomRadius  = 13.0f;
static const CGFloat kMinBottomPadding = 3.0f;
static const CGFloat kMaxBottomPadding = 5.0f;
static const CGFloat kMinArrowSize     = 2.0f;
static const CGFloat kMaxArrowSize     = 3.0f;
static const CGFloat kMinArrowRadius   = 4.0f;
static const CGFloat kMaxArrowRadius   = 6.0f;
static const CGFloat kMaxDistance      = 33.0f;
static const CGFloat kDistanceForTopCircle = kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding;//下拉到完整显示上面的大圆需要的距离

@interface RaindropRefreshView(){
    CAShapeLayer *_shapeLayer;
    CAShapeLayer *_arrowLayer;
    CAShapeLayer *_highlightLayer;
    BOOL _refreshing;
}
@end

@implementation RaindropRefreshView
@synthesize shapeColor;
@synthesize refreshingIndicator;
@synthesize pullHeightRequired = _pullHeightRequired;

static inline CGFloat lerp(CGFloat a, CGFloat b, CGFloat p){
    return a + (b - a) * p;
}

-(void)setupControl{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pullHeightRequired = kMaxDistance + kDistanceForTopCircle;
    
    refreshingIndicator.center = CGPointMake(floor(self.frame.size.width / 2), floor(self.frame.size.height / 2));
    refreshingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    refreshingIndicator.alpha = 0;
    [self addSubview:refreshingIndicator];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = shapeColor.CGColor;
    _shapeLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    _shapeLayer.lineWidth = 0.5;
    _shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
    _shapeLayer.shadowOffset = CGSizeMake(0, 1);
    _shapeLayer.shadowOpacity = 0.4;
    _shapeLayer.shadowRadius = 0.5;
    [self.layer addSublayer:_shapeLayer];
    
    _arrowLayer = [CAShapeLayer layer];
    _arrowLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    _arrowLayer.lineWidth = 0.5;
    _arrowLayer.fillColor = [[UIColor whiteColor] CGColor];
    [_shapeLayer addSublayer:_arrowLayer];
    
    _highlightLayer = [CAShapeLayer layer];
    _highlightLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    [_shapeLayer addSublayer:_highlightLayer];
}

- (void)layoutSubviews{
    if (_refreshing) {
        // Keep thing pinned at the top
        refreshingIndicator.center = CGPointMake(floor(self.frame.size.width / 2), MIN(self.pullHeightRequired / 2, self.frame.size.height - self.pullHeightRequired/ 2));
    } else {
        if (self.frame.size.height == 0) {
            _shapeLayer.path = nil;
            _shapeLayer.shadowPath = nil;
            _arrowLayer.path = nil;
            _highlightLayer.path = nil;
            return;
        }
        
        //随着下拉，外界会修改self.frame使控件显示出来。当圆球部分完全显示出来时，verticalShift就会大于0；接下来显示圆球下拉变细的动画，这时percentage就会从1逐渐减小至0
        CGFloat verticalShift = MAX(0, self.frame.size.height - kDistanceForTopCircle);
        CGFloat distance = MIN(kMaxDistance, verticalShift);
        CGFloat percentage = 1 - (distance / kMaxDistance);
        
        CGFloat currentTopPadding = lerp(kMinTopPadding, kMaxTopPadding, percentage);
        CGFloat currentTopRadius = lerp(kMinTopRadius, kMaxTopRadius, percentage);
        CGFloat currentBottomRadius = lerp(kMinBottomRadius, kMaxBottomRadius, percentage);
        CGFloat currentBottomPadding =  lerp(kMinBottomPadding, kMaxBottomPadding, percentage);
        
        CGPoint bottomOrigin = CGPointMake(floor(self.bounds.size.width / 2), self.bounds.size.height - currentBottomPadding -currentBottomRadius);//下拉到显示完整上面的圆后，就要拉出显示下面的圆，下面圆的圆心
        CGPoint topOrigin = CGPointZero;//上面圆的圆心
        if (distance == 0) {
            topOrigin = CGPointMake(floor(self.bounds.size.width / 2), bottomOrigin.y);
        } else {
            topOrigin = CGPointMake(floor(self.bounds.size.width / 2), currentTopPadding + currentTopRadius);
            if (percentage == 0) {
                bottomOrigin.y -= (fabs(verticalShift) - kMaxDistance);
            }
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        //Top semicircle
        CGPathAddArc(path, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
        
        //Left curve
        CGPoint leftCp1 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
        CGPoint leftCp2 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
        CGPoint leftDestination = CGPointMake(bottomOrigin.x - currentBottomRadius, bottomOrigin.y);
        
        CGPathAddCurveToPoint(path, NULL, leftCp1.x, leftCp1.y, leftCp2.x, leftCp2.y, leftDestination.x, leftDestination.y);
        
        //Bottom semicircle
        CGPathAddArc(path, NULL, bottomOrigin.x, bottomOrigin.y, currentBottomRadius, M_PI, 0, YES);
        
        //Right curve
        CGPoint rightCp2 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
        CGPoint rightCp1 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
        CGPoint rightDestination = CGPointMake(topOrigin.x + currentTopRadius, topOrigin.y);
        
        CGPathAddCurveToPoint(path, NULL, rightCp1.x, rightCp1.y, rightCp2.x, rightCp2.y, rightDestination.x, rightDestination.y);
        CGPathCloseSubpath(path);
        
        // Set paths
        _shapeLayer.path = path;
        _shapeLayer.shadowPath = path;
        
        // Add the arrow shape
        CGFloat currentArrowSize = lerp(kMinArrowSize, kMaxArrowSize, percentage);
        CGFloat currentArrowRadius = lerp(kMinArrowRadius, kMaxArrowRadius, percentage);
        CGFloat arrowBigRadius = currentArrowRadius + (currentArrowSize / 2);
        CGFloat arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2);
        CGMutablePathRef arrowPath = CGPathCreateMutable();
        //圆弧显示效果：随着下拉，画出的圆弧从0到接近闭合；当上面大圆显示完整开始显示小圆时，圆弧同步旋转；当小圆下拉到最下端后，圆弧旋转速度减慢
        const CGFloat kProportionBeginToShowCircle = 0.25;//逐渐拉出上面的大圆时，拉出0.25倍距离才开始显示圆弧
        const CGFloat kMaxAngle = 0.93 * 2 * M_PI;//最多显示整个圆的0.93倍圆弧
        const CGFloat kRotationMultiplier = 1.5;//开始旋转的速率
        if (verticalShift == 0) {
            CGFloat proportion = self.frame.size.height / kDistanceForTopCircle;
            if (proportion > kProportionBeginToShowCircle) {
                CGFloat angle = (proportion - kProportionBeginToShowCircle) / (1 - kProportionBeginToShowCircle) * kMaxAngle;
                CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowBigRadius, 0, angle, NO);
                CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowSmallRadius, angle, 0, YES);
            }
            else{
                CGPathMoveToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y);//即使不需要显示圆弧，也要在arrowPath中设置一个点，否则当CGPathCloseSubpath时会报错“no current point”
            }
        }
        else if(verticalShift < kMaxDistance){
            //拉到开始显示下面的小圆后，圆弧开始旋转
            CGFloat startAngle = verticalShift * kRotationMultiplier / kDistanceForTopCircle * 2 * M_PI;
            CGFloat endAngle = startAngle + kMaxAngle;
            CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowBigRadius, startAngle, endAngle, NO);
            CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowSmallRadius, endAngle, startAngle, YES);
        }
        else{
            //小圆下拉到最下端后，圆弧旋转速度减慢
            CGFloat startAngle = (kMaxDistance * kRotationMultiplier + (verticalShift - kMaxDistance) * 0.5) / kDistanceForTopCircle * 2 * M_PI;//旋转减慢到0.5倍
            CGFloat endAngle = startAngle + kMaxAngle;
            CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowBigRadius, startAngle, endAngle, NO);
            CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowSmallRadius, endAngle, startAngle, YES);
        }
        CGPathCloseSubpath(arrowPath);
        _arrowLayer.path = arrowPath;
        [_arrowLayer setFillRule:kCAFillRuleEvenOdd];
        CGPathRelease(arrowPath);
        
        // Add the highlight shape
        CGMutablePathRef highlightPath = CGPathCreateMutable();
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y + 1.25, currentTopRadius, M_PI, 0, NO);
        
        _highlightLayer.path = highlightPath;
        [_highlightLayer setFillRule:kCAFillRuleNonZero];
        
        CGPathRelease(highlightPath);
        CGPathRelease(path);
    }
}

- (void)beginRefreshing:(BOOL)animated{
    if (_refreshing) {
        return;
    }
    if (animated) {
        // Start the shape disappearance animation
        CGFloat radius = lerp(kMinBottomRadius, kMaxBottomRadius, 0.2);
        CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
        pathMorph.duration = 0.15;
        pathMorph.fillMode = kCAFillModeForwards;
        pathMorph.removedOnCompletion = NO;
        CGMutablePathRef toPath = CGPathCreateMutable();
        CGPoint topOrigin = CGPointMake(floor(self.bounds.size.width / 2), kMaxTopPadding + kMaxTopRadius);
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, 0, M_PI, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y);
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, M_PI, 0, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y);
        CGPathCloseSubpath(toPath);
        pathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:pathMorph forKey:nil];
        CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowPathMorph.duration = 0.15;
        shadowPathMorph.fillMode = kCAFillModeForwards;
        shadowPathMorph.removedOnCompletion = NO;
        shadowPathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:shadowPathMorph forKey:nil];
        CGPathRelease(toPath);
        CABasicAnimation *shapeAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        shapeAlphaAnimation.duration = 0.1;
        shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1;
        shapeAlphaAnimation.toValue = [NSNumber numberWithFloat:0];
        shapeAlphaAnimation.fillMode = kCAFillModeForwards;
        shapeAlphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:shapeAlphaAnimation forKey:nil];
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.1;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        refreshingIndicator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        [CATransaction commit];
        [UIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            refreshingIndicator.alpha = 1;
            refreshingIndicator.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:nil];
    }
    else {
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.0001;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:alphaAnimation forKey:nil];
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        refreshingIndicator.alpha = 1;
        refreshingIndicator.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }
    
    _refreshing = YES;
}

- (void)endRefreshing{
    if (_refreshing) {
        [UIView animateWithDuration:0.4 animations:^{
            refreshingIndicator.alpha = 0;
            refreshingIndicator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        } completion:^(BOOL finished) {
            [_shapeLayer removeAllAnimations];
            _shapeLayer.path = nil;
            _shapeLayer.shadowPath = nil;
            _shapeLayer.position = CGPointZero;
            [_arrowLayer removeAllAnimations];
            _arrowLayer.path = nil;
            [_highlightLayer removeAllAnimations];
            _highlightLayer.path = nil;
            _refreshing = NO;
        }];
    }
}

@end
