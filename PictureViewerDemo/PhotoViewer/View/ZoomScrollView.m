//
//  ZoomScrollView.m
//  Bus
//
//  Created by Shane on 2017/7/6.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "ZoomScrollView.h"

@interface ZoomScrollView ()<UIGestureRecognizerDelegate>

@property (assign, nonatomic) NSUInteger tapCount;

@end

@implementation ZoomScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI
{
    self.panGestureRecognizer.delegate = self;
}
#pragma mark-
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    self.tapCount = touch.tapCount;
    CGPoint tmp = [self.panGestureRecognizer velocityInView:self];
    NSLog(@"%f",tmp.y);
    return YES;
}

// 同时让其他手势也响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 手势是pan时，contentoffset.y == 0 让其他手势也同时响应, 外部检测手势方向。
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.contentOffset.y == 0 && self.tapCount == 1) {
            return YES;
        }
    }
   
    return NO;
}

@end
