//
//  PictureViewerTransition.m
//  Bus
//
//  Created by Shane on 2017/5/8.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "PictureViewerTransition.h"

static CGFloat const kViewAnimationDuration = 0.33;
//static CGFloat const kTransitionDuration = 0.4;

@implementation PictureViewerTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return kViewAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{

    
}

@end


@implementation PictureViewerPresentTransition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController<PictureViewerTransitionToViewController> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<PictureViewerTransitionToViewController> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toVC.view];
    toVC.view.frame = fromVC.view.bounds;
    
    toVC.view.backgroundColor = [UIColor clearColor];
    toVC.backgroundView.alpha = 0;
    
    // data
    CGRect cellRect = self.fromRect;
    PictureViewerData *data = self.data;
    
    UIView *animationView = [UIView new];
    animationView.clipsToBounds = YES;
    [toVC.view addSubview:animationView];
    [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(cellRect.origin.x);
        make.top.mas_equalTo(cellRect.origin.y);
        make.size.mas_equalTo(cellRect.size);
    }];
    
    UIImageView *thumbImageView = [UIImageView new];
    thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    [animationView addSubview:thumbImageView];
    
    CGFloat sacleWH = 1;
    
    // 长图 从顶部不动展开
    if (([UIImage imageTypeWithSize:data.realSize] == BusImageTypeLong) && ![data.ext isEqualToString:@"gif"]) {
        // 长图的缩略图 w/h 一定为1/2
        sacleWH = 1.0/2.0;
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(animationView);
            make.width.equalTo(animationView);
            make.height.equalTo(animationView.mas_width).multipliedBy(1.0/sacleWH);
        }];
    }// 竖图
    else if (data.realSize.height/data.realSize.width > 1 && ![data.ext isEqualToString:@"gif"]){
        sacleWH = data.realSize.width/data.realSize.height;
        if (isnan(sacleWH) || isinf(sacleWH) || sacleWH == 0) {
            sacleWH = 1;
        }
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(animationView);
            make.width.equalTo(animationView);
            make.height.equalTo(animationView.mas_width).multipliedBy(1.0/sacleWH);
        }];
    }// 非长图 从中间展开
    else{
        sacleWH = data.realSize.width/data.realSize.height;
        if (isnan(sacleWH) || isinf(sacleWH) || sacleWH == 0) {
            sacleWH = 1;
        }
        
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.trailing.equalTo(animationView);
        }];
    }
    
    // 1 有缩略图存在
    if (self.thumbImage) {
        thumbImageView.image = self.thumbImage;
        thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    }// 2 无缩略图 显示占位图
    else{
        thumbImageView.backgroundColor = APPCONFIG.colorConfig.color(@"B29");
        thumbImageView.contentMode = UIViewContentModeCenter;
        [thumbImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.trailing.equalTo(animationView);
        }];
        sacleWH = 1;
    }
    
    [thumbImageView layoutIfNeeded];
    [toVC.view layoutIfNeeded];
    
    if ([self.delegate respondsToSelector:@selector(pictreViewerTransitionShowAnimationReady)]) {
        [self.delegate pictreViewerTransitionShowAnimationReady];
    }
    
    // 全屏展示
    CGRect fullRect = CGRectZero;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.width/sacleWH;
    if (h > toVC.view.frame.size.height) {
        fullRect = CGRectMake(0, 0, w, h);
    }
    else{
        fullRect = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height-h)/2, w, h);
    }
    [animationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(fullRect.origin.x);
        make.top.mas_equalTo(fullRect.origin.y);
        make.size.mas_equalTo(fullRect.size);
    }];
    
    [UIView animateWithDuration:kViewAnimationDuration
                          delay:0.f
         usingSpringWithDamping:1
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         toVC.backgroundView.alpha = 1;
                         [toVC.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [animationView removeFromSuperview];
                         toVC.backgroundView.hidden = YES;
                         [transitionContext completeTransition:YES];
                     }];
}

@end


@implementation PictureViewerDismissTransition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect cellRect = self.toRect;
    PictureViewerData *data = self.data;
    
    // dismiss时 rect为zero，动画使用渐隐动画
    if (CGRectEqualToRect(cellRect, CGRectZero) || data == nil) {
        [UIView animateWithDuration:0.2 animations:^{
            fromVC.view.alpha = 0;
        } completion:^(BOOL finished) {
             [transitionContext completeTransition:YES];
        }];
        return;
    }
    
    UIView *animationView = [UIView new];
    animationView.clipsToBounds = YES;
    [toVC.view addSubview:animationView];
    
    UIImageView *thumbImageView = [UIImageView new];
    thumbImageView.clipsToBounds = YES;
    thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    [animationView addSubview:thumbImageView];
    
    CGFloat sacleWH = data.realSize.width/data.realSize.height;
    if (isnan(sacleWH) || isinf(sacleWH) || sacleWH == 0) {
        sacleWH = 1;
    }
    // 长图 从顶部展开
    if ([UIImage imageTypeWithSize:data.realSize] == BusImageTypeLong && ![data.ext isEqualToString:@"gif"]) {
        // 长图的缩略图 w/h 一定为1/2
        sacleWH = 1.0/2.0;
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(animationView);
            make.width.equalTo(animationView);
            make.height.equalTo(animationView.mas_width).multipliedBy(1.0/sacleWH);
        }];
    }// 竖图
    else if (data.realSize.height/data.realSize.width > 1 && ![data.ext isEqualToString:@"gif"]){
        sacleWH = data.realSize.width/data.realSize.height;
        if (isnan(sacleWH) || isinf(sacleWH) || sacleWH == 0) {
            sacleWH = 1;
        }
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(animationView);
            make.width.equalTo(animationView);
            make.height.equalTo(animationView.mas_width).multipliedBy(1.0/sacleWH);
        }];
    }// 非长图 从中间展开
    else{
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.trailing.equalTo(animationView);
        }];
    }
    
    // 从缓存获取图片
    if (self.thumbImage) {
        thumbImageView.image = self.thumbImage;
    }
    else{
        thumbImageView.backgroundColor = APPCONFIG.colorConfig.color(@"B1");
        thumbImageView.contentMode = UIViewContentModeCenter;
        sacleWH = 1;
    }
    //    cell.hidden = YES;
    
    CGRect fullRect;
    CGFloat w = toVC.view.frame.size.width;
    CGFloat h = toVC.view.frame.size.width/sacleWH;
    if (h > toVC.view.frame.size.height) {
        fullRect = CGRectMake(0, 0, w, h);
    }
    else{
        fullRect = CGRectMake(0, (toVC.view.frame.size.height-h)/2, w, h);
    }
    [animationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(fullRect.origin.x);
        make.top.mas_equalTo(fullRect.origin.y);
        make.size.mas_equalTo(fullRect.size);
    }];
    [toVC.view layoutIfNeeded];
    
    [animationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(cellRect.origin.x);
        make.top.mas_equalTo(cellRect.origin.y);
        make.size.mas_equalTo(cellRect.size);
    }];
    
    [UIView animateWithDuration:0.1 animations:^{
        fromVC.view.alpha = 0;
    }];
 
    [UIView animateWithDuration:kViewAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:1
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [toVC.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [animationView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
  }

@end

@implementation PictureViewerInteractiveDismissTransition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
//        UIViewController<PictureViewerTransitionToViewController> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<PictureViewerTransitionToViewController> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
//    fromVC.view.backgroundColor = [UIColor clearColor];
//    fromVC.backgroundView.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:kViewAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
//                         fromVC.backgroundView.alpha = 0;
                         fromVC.view.frame = CGRectMake(0, fromVC.view.height, fromVC.view.width, fromVC.view.height);
                     } completion:^(BOOL finished) {
                         
                             [transitionContext completeTransition:!self.restoreDisplay];

                         
                     }];
}

@end

@interface PictureViewerPercentInteractiveTransition ()

@property (strong, nonatomic) id <UIViewControllerContextTransitioning> contextData;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@end

@implementation PictureViewerPercentInteractiveTransition

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Always call super first.
    [super startInteractiveTransition:transitionContext];
    
    // Save the transition context for future reference.
    self.contextData = transitionContext;
    
    // Create a pan gesture recognizer to monitor events.
    self.panGesture = [[UIPanGestureRecognizer alloc]
                       initWithTarget:self action:@selector(handleSwipeUpdate:)];
    self.panGesture.maximumNumberOfTouches = 1;
    
    // Add the gesture recognizer to the container view.
    UIView* container = [transitionContext containerView];
    [container addGestureRecognizer:self.panGesture];
}

-(void)handleSwipeUpdate:(UIGestureRecognizer *)gestureRecognizer {
    UIView* container = [self.contextData containerView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the translation value at the beginning of the gesture.
        [self.panGesture setTranslation:CGPointMake(0, 0) inView:container];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // Get the current translation value.
        CGPoint translation = [self.panGesture translationInView:container];
        
        // Compute how far the gesture has travelled vertically,
        //  relative to the height of the container view.
        CGFloat percentage = fabs(translation.y / CGRectGetHeight(container.bounds));
        
        // Use the translation value to update the interactive animator.
        [self updateInteractiveTransition:percentage];
    }
    else if (gestureRecognizer.state >= UIGestureRecognizerStateEnded) {
        // Finish the transition and remove the gesture recognizer.
        [self finishInteractiveTransition];
        [[self.contextData containerView] removeGestureRecognizer:self.panGesture];
    }
}

@end
