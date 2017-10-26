//
//  PictureZoomViewController.m
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/25.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import "PictureZoomViewController.h"

@interface PictureZoomViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat currentZoomScale;

@end

@implementation PictureZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

// 更新 约束，保持时刻居中
- (void)updateContentViewWithSize:(CGSize)viewSize {
    // 设置 imageView 上 左 下 右位置，使其居中
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGFloat viewWidth = viewSize.width;
    CGFloat viewHeight = viewSize.height;
    
    CGFloat hPadding = 0;
    CGFloat vPadding = 0;
    
    hPadding = (viewWidth - self.currentZoomScale * imageWidth) / 2;
    if (hPadding < 0) hPadding = 0;
    
    vPadding = (viewHeight - self.currentZoomScale * imageHeight) / 2;
    if (vPadding < 0) vPadding = 0;
    
    self.scrollView.contentSize = CGSizeMake(hPadding*2 + (int)(self.currentZoomScale * imageWidth), vPadding*2 + (int)(self.currentZoomScale * imageHeight));
    
    self.imageView.frame = CGRectMake(0, 0, (self.currentZoomScale * imageWidth), (self.currentZoomScale * imageHeight));
    self.imageView.center = CGPointMake((self.currentZoomScale * imageWidth) * 0.5 + hPadding,
                                            (self.currentZoomScale * imageHeight) * 0.5 + vPadding);
}

#pragma mark- scrollView delegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

@end
