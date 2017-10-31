
//
//  PictureZoomViewController.m
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/25.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import "PictureZoomViewController.h"
#import "UIImageView+WebCache.h"

@interface PictureZoomViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat currentZoomScale;

@end

@implementation PictureZoomViewController

#pragma mark- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.data.thumbUrl]];
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:cacheKey];
    if (image == nil) {
        image = [UIImage imageNamed:@""];
    }

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.data.sourceUrl]
                      placeholderImage:image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
}

- (void)didDisplay {
    
}

#pragma mark- private
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

- (void)caluZoomScaleWithSize:(CGSize)size {
    // 1 宽度填满 高度等比。
    if (self.pictureShowModel == PictureShowModelWidthFirst) {
        self.currentZoomScale = size.width/self.data.realSize.width;
    }// 2 fillFit
    else {
        self.currentZoomScale = MIN(size.width / self.data.realSize.width,
                                    size.height / self.data.realSize.height);
    }
    
    if (isnan(self.currentZoomScale) || isinf(self.currentZoomScale)) {
        self.currentZoomScale = 1;
    }
    
    self.scrollView.minimumZoomScale = self.currentZoomScale;
    self.scrollView.maximumZoomScale = self.currentZoomScale+1;
    self.scrollView.zoomScale = self.currentZoomScale;
    
    [self updateContentViewWithSize:size];
}

#pragma mark- scrollView delegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"缩放:s:%f",scrollView.zoomScale);
    self.currentZoomScale = scrollView.zoomScale;
    [self updateContentViewWithSize:self.view.frame.size];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark- setters
- (void)setData:(PictureData *)data {
    [self caluZoomScaleWithSize:self.view.frame.size];
}

@end
