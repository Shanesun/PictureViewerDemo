//
//  SSZoomVieweController
//  Bus
//
//  Created by Shane on 2017/3/9.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "SSZoomVieweController.h"

@interface SSZoomVieweController () <UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat currentZoomScale;

@end

@implementation SSZoomVieweController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configUI];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      [self caluZoomScaleWithSize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)configUI
{
    self.scrollView = [ZoomScrollView new];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.gifPlayerView = [GifPlayerView new];
    [self.scrollView addSubview:self.gifPlayerView];
    
    UITapGestureRecognizer *backgroundSigleTap = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(backgroundSigleTapClicked:)];
    [self.view addGestureRecognizer:backgroundSigleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(doubleTapClicked:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self.gifPlayerView addGestureRecognizer:doubleTap];
    
    [backgroundSigleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)updateZoomWithPlayerView:(GifPlayerView *)gifPlayerView
{
    if (gifPlayerView) {
        self.gifPlayerView = gifPlayerView;
    }
}

- (void)caluZoomScaleWithSize:(CGSize)size
{
    // 满足宽度优先。
    self.currentZoomScale = size.width/self.gifPlayerView.orignSize.width;
    if (isnan(self.currentZoomScale) || isinf(self.currentZoomScale)) {
        self.currentZoomScale = 1;
    }
    
    // fit模式
//    float minZoom = MIN(scrollViewBounds.size.width / image.size.width,
//                        scrollViewBounds.size.height / image.size.height);

    self.scrollView.minimumZoomScale = self.currentZoomScale;
    self.scrollView.maximumZoomScale = self.currentZoomScale+1;
    self.scrollView.zoomScale = self.currentZoomScale;
    
    [self updateContentViewWithSize:size];
}

#pragma mark- Acitons

- (void)backgroundSigleTapClicked:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(pictureViewer:backgroundTap:)]) {
        [self.delegate pictureViewer:self backgroundTap:recognizer];
    }
}

- (void)doubleTapClicked:(UITapGestureRecognizer *)recognizer
{
    if (self.currentZoomScale > self.scrollView.minimumZoomScale){
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else{
        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale
                                      withCenter:[recognizer locationInView:recognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark- private meathods
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect = CGRectZero;
    
    zoomRect.size.height = (int)self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = (int)self.scrollView.frame.size.width  / scale;
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

#pragma mark- setters and getters
- (void)setPlayData:(PictureViewerData *)playData
{
    // 初始状态
    _playData = playData;
    [self.scrollView setContentOffset:CGPointZero];
    
    self.gifPlayerView.playData = playData;
    [self.view layoutIfNeeded];
    [self caluZoomScaleWithSize:self.view.frame.size];
}

#pragma mark- scrollView zoom

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.gifPlayerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"缩放:s:%f",scrollView.zoomScale);
    self.currentZoomScale = scrollView.zoomScale;
    [self updateContentViewWithSize:self.view.frame.size];
}

// 更新 约束，保持时刻居中
- (void)updateContentViewWithSize:(CGSize)viewSize;
{
    // 设置 imageView 上 左 下 右位置，使其居中
    CGFloat imageWidth = self.gifPlayerView.orignSize.width;
    CGFloat imageHeight = self.gifPlayerView.orignSize.height;
    
    CGFloat viewWidth = viewSize.width;
    CGFloat viewHeight = viewSize.height;
    
    CGFloat hPadding = 0;
    CGFloat vPadding = 0;
    
    hPadding = (viewWidth - self.currentZoomScale * imageWidth) / 2;
    if (hPadding < 0) hPadding = 0;

    vPadding = (viewHeight - self.currentZoomScale * imageHeight) / 2;
    if (vPadding < 0) vPadding = 0;
    
    self.scrollView.contentSize = CGSizeMake(hPadding*2 + (int)(self.currentZoomScale * imageWidth), vPadding*2 + (int)(self.currentZoomScale * imageHeight));

    self.gifPlayerView.frame = CGRectMake(0, 0, (self.currentZoomScale * imageWidth), (self.currentZoomScale * imageHeight));
    self.gifPlayerView.center = CGPointMake((self.currentZoomScale * imageWidth) * 0.5 + hPadding,
                                 (self.currentZoomScale * imageHeight) * 0.5 + vPadding);
}



@end
