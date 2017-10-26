//
//  PictureViewerCell.m
//  Bus
//
//  Created by Shane on 2017/3/14.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "PictureViewerCell.h"
#import "Mp4ProgressVIew.h"

@interface PictureViewerCell () <GifPlayerViewDelegate>

@property (strong, nonatomic) Mp4ProgressVIew *progressView;

@end

@implementation PictureViewerCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self congifUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self congifUI];
    }
    return self;
}

- (void)setData:(PictureViewerData *)data
{
    _data = data;
    self.progressView.hidden = YES;
    
    self.pictureViewer.playData = _data;
}

- (void)didShow
{
    self.pictureViewer.gifPlayerView.delegate = self;
    [self.pictureViewer.gifPlayerView play];
}

- (void)congifUI
{
    self.backgroundColor = [UIColor blackColor];
    
    UIImageView *placeholderImageView = [UIImageView new];
    CGFloat width = self.frame.size.width;
    if (self.frame.size.width > self.frame.size.height) {
        width = self.frame.size.height;
    }
    placeholderImageView.bounds = CGRectMake(0, 0, width, width);
    placeholderImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    placeholderImageView.backgroundColor = APPCONFIG.colorConfig.color(@"B29");
    placeholderImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:placeholderImageView];
    
    self.pictureViewer = [SSZoomVieweController new];
    self.pictureViewer.view.backgroundColor = [UIColor clearColor];
    [self addSubview:self.pictureViewer.view];
    [self.pictureViewer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    self.progressView = [[Mp4ProgressVIew alloc] init];
    self.progressView.frame = self.bounds;
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.hidden = YES;
    [self addSubview:self.progressView];
    
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapClicked:)];
    [self.progressView addGestureRecognizer:backgroundTap];
}

#pragma mark- Actions
- (void)backgroundTapClicked:(UITapGestureRecognizer *)recognizer
{
    if ([self.pictureViewer.delegate respondsToSelector:@selector(pictureViewer:backgroundTap:)]) {
        [self.pictureViewer.delegate pictureViewer:self.pictureViewer backgroundTap:recognizer];
    }
}

#pragma mark- GifPlayer delegate
- (void)gifPlayerViewWillDownload:(GifPlayerView *)playerView downloadProgress:(CGFloat)progress
{
    // 断网下避免 闪一下进度条
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return;
    }
    
    self.progressView.hidden = NO;
    self.progressView.progress = progress;
}

- (void)gifPlayerView:(GifPlayerView *)playerView downloadProgress:(CGFloat)progress
{
    self.progressView.hidden = NO;
    self.progressView.progress = progress;
}

- (void)gifPlayerViewEndDownload:(GifPlayerView *)playerView error:( NSError * _Nullable )error
{
    self.progressView.hidden = YES;
    
    if (error) {
//        [SVProgressHUD showErrorWithStatus:@"加载失败,稍后重试"];
    }
}



@end
