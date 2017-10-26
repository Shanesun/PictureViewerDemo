//
//  GifPlayerView.m
//  Bus
//
//  Created by Shane on 2017/3/9.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "GifPlayerView.h"
#import "Mp4Player.h"
#import "Mp4ProgressVIew.h"
#import "AppDelegate.h"
#import "SSZoomVieweController.h"
#import "Mp4PreloadingManager.h"

@implementation PictureViewerData

@end

@interface GifPlayerView () <Mp4PlayerDelegate>

@property (strong, nonatomic) YYAnimatedImageView *imageView;
@property (strong, nonatomic) Mp4Player *mp4View;
@property (strong, nonatomic) UIImageView *thumbImageView;

@end

@implementation GifPlayerView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)dealloc
{
    [_mp4View stop];
}

- (void)configUI
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([UIImage imageTypeWithSize:_playData.realSize] == BusImageTypeLong && ![_playData.ext.lowercaseString isEqualToString:@"gif"]) {
//        CGFloat w = self.bounds.size.width/self.thumbImageView.transform.a;
        //        self.thumbImageView.frame = CGRectMake(0, 0, w, w*2);
        // 如果是长图缩略图 高度/宽度 2.0/1.0
        _thumbImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width*2);
    }
    else{
        _thumbImageView.frame = self.bounds;
    }
    
    _imageView.frame = self.bounds;
    _mp4View.frame = self.bounds;
}


#pragma mark- public methods
- (void)setPlayData:(PictureViewerData *)playData
{
    _playData = playData;
    
    // 初始化
    self.thumbImageView.image = nil;
    self.imageView.image = nil;
    self.superview.backgroundColor = [UIColor clearColor];
    [self.mp4View stop];
    
    __weak __typeof(self)weakSelf = self;
    // 缩略图
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:_playData.thumbUrl]
                                placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     if (image && [weakSelf.playData.thumbUrl isEqualToString:url.absoluteString]) {
                                         weakSelf.superview.backgroundColor = [UIColor blackColor];
                                     }
    }];
    
    // gif/image 先显示成静态，等didAppear后gif开始动画
    UIImage *sourceImage = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:_playData.sourceUrl]]];
    if (sourceImage) {
        self.imageView.image = sourceImage;
        [self.imageView stopAnimating];
        self.superview.backgroundColor = [UIColor blackColor];
    }
}

- (void)play
{
    if (self.playData.mp4Url && self.playData.mp4Url.length > 0) {
        [self playMp4:self.playData.mp4Url];
    }
    else{
        [self playImage:self.playData.sourceUrl];
    }
}

- (void)stop
{
    [self.imageView stopAnimating];
    [self.mp4View stop];
}

- (CGSize)orignSize
{
    // 保护
    if (self.playData.realSize.width == 0 || self.playData.realSize.height == 0) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    }
    
    return CGSizeMake(self.playData.realSize.width/[UIScreen mainScreen].scale, self.playData.realSize.height/[UIScreen mainScreen].scale);
}

#pragma mark helper
+ (void)predownloadWithUrl:(NSString *)urlStr isMp4:(BOOL)isMp4
{
    if (urlStr == nil) {
        return;
    }
    
    if (isMp4) {
        [Mp4PreloadingManager predownloadUrls:@[urlStr]];
    }
    else{
        [GifPlayerView downloadImageWithUrl:urlStr willDownloadBlock:nil downloadFinish:nil progress:nil];
    }
}

+ (void)downloadImageWithUrl:(NSString *)urlStr
           willDownloadBlock:(void(^)(void))willDownloadBlock
              downloadFinish:(YYWebImageCompletionBlock)downloadFinish
                    progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, NSURL *url))progressBlock
{
    if (urlStr == nil) {
        return;
    }
    
    // 1 存在缓存时
    UIImage *sourceImage = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:urlStr]]];
    if (sourceImage && downloadFinish) {
        downloadFinish(sourceImage, [NSURL URLWithString:urlStr],YYWebImageFromMemoryCache,YYWebImageStageFinished,nil);
        return;
    }
    
    if (willDownloadBlock) {
        willDownloadBlock();
    }
    
    // 3 已经在下载队列中，正在下载
    NSOperationQueue *queue = [YYWebImageManager sharedManager].queue;
    for (YYWebImageOperation *operation in queue.operations) {
        if ([operation.request.URL.absoluteString isEqualToString:urlStr]) {
            NSLog(@"-- downing --");
            // 有可能潜在问题：有可能存在两张相同地址的图片同事请求。这个第一个请求的block就会被替换掉。但先阶段与后台确认不存在2张相同地址的图片。暂保留。
            if (downloadFinish) {
                [operation setValue:downloadFinish forKey:@"completion"];
            }
            if (progressBlock) {
                
                YYWebImageProgressBlock tmpProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                    progressBlock(receivedSize,expectedSize,operation.request.URL);
                };
                [operation setValue:tmpProgressBlock forKey:@"progress"];
            }
            return;
        }
    }
    
    // 4 开始下载
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:urlStr]
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                      if (progressBlock) {
                                                          progressBlock(receivedSize,expectedSize,[NSURL URLWithString:urlStr]);
                                                      }
                                                  }
                                                 transform:nil
                                                completion:downloadFinish];
}

#pragma mark- private methods
- (void)playImage:(NSString *)url
{
    self.imageView.hidden = NO;
    self.mp4View.hidden = YES;
    
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    __weak __typeof(self)weakSelf = self;
    
   YYWebImageCompletionBlock downloadFinish = ^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           // 1 download url != current image url
           if (![weakSelf.playData.sourceUrl isEqualToString:url.absoluteString]) {
               return;
           }
           
           // 2 一致，且image返回正常
           if (image) {
               weakSelf.imageView.image = image;
               [weakSelf.imageView startAnimating];
               weakSelf.superview.backgroundColor = [UIColor blackColor];
           }
           
           [weakSelf gifPlayerViewEndDownloadWithError:error];
       });
    };
    
    void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL *url) = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL *downUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat persent = (float)receivedSize/(float)expectedSize;
            NSLog(@"---down image=%f \nurl:%@---",persent,imageUrl.absoluteString);
            if ([weakSelf.playData.sourceUrl isEqualToString:downUrl.absoluteString]) {
                [weakSelf downingProgress:persent];
            }
        });
    };
    
    void(^willDownloadBlock)(void) = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(gifPlayerViewWillDownload:downloadProgress:)]) {
            [weakSelf.delegate gifPlayerViewWillDownload:weakSelf downloadProgress:0];
        }
    };
    
    // 1 存在缓存时
    UIImage *sourceImage = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]]];
    if (sourceImage) {
        downloadFinish(sourceImage, [NSURL URLWithString:url],YYWebImageFromMemoryCache,YYWebImageStageFinished,nil);
        return;
    }
    
    [GifPlayerView downloadImageWithUrl:url
                      willDownloadBlock:willDownloadBlock
                         downloadFinish:downloadFinish
                               progress:progressBlock];
}

- (void)gifPlayerViewEndDownloadWithError:(NSError *)error
{
    // 下载失败时 tableview 不能滑动
    UIView *nextView = self.superview;
    while (nextView) {
        if ([nextView isKindOfClass:[SSZoomVieweController class]]) {
            SSZoomVieweController *viewer = (SSZoomVieweController *)nextView;
            if (error) {
                viewer.scrollView.scrollEnabled = NO;
            }
            else{
                 viewer.scrollView.scrollEnabled = YES;
            }
            
            
            break;
        }
        nextView = nextView.superview;
    }
    
    if ([self.delegate respondsToSelector:@selector(gifPlayerViewEndDownload:error:)]) {
        [self.delegate gifPlayerViewEndDownload:self error:error];
    }
}

- (void)playMp4:(NSString *)url
{
    self.imageView.hidden = YES;
    self.mp4View.hidden = NO;
    
    [self.mp4View willPlayUrl:url];
}

- (void)downingProgress:(CGFloat)progress
{
    if ([self.delegate respondsToSelector:@selector(gifPlayerView:downloadProgress:)]) {
        [self.delegate gifPlayerView:self downloadProgress:progress];
    }
}

#pragma mark- mp4player delegate
- (void)mp4PlayerWillDownload:(Mp4Player *)player progress:(CGFloat)progress
{
    if (![player.playUrl isEqualToString:self.playData.mp4Url]) {
        return;
    }
    [self downingProgress:progress];
}

- (void)mp4Player:(Mp4Player *)player downingProgress:(CGFloat)progress
{
    if (![player.playUrl isEqualToString:self.playData.mp4Url]) {
        return;
    }
    [self downingProgress:progress];
}

- (void)mp4PlayerEndDownload:(Mp4Player *)player error:(NSError *)error
{
    if (![player.playUrl isEqualToString:self.playData.mp4Url]) {
        return;
    }
    
    if (error == nil) {
        self.superview.backgroundColor = [UIColor blackColor];
    }
    
    [self gifPlayerViewEndDownloadWithError:error];
}

#pragma mark- setter and getter
- (YYAnimatedImageView *)imageView
{
    if (!_imageView) {
        _imageView = [YYAnimatedImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.needLoop = YES;
        _imageView.frame = self.bounds;
        _imageView.hidden = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (Mp4Player *)mp4View
{
    if (!_mp4View) {
        _mp4View = [Mp4Player new];
        _mp4View.delegate = self;
        _mp4View.isPlayLoop = YES;
        _mp4View.hidden = YES;
        _mp4View.frame = self.bounds;
        [self addSubview:_mp4View];
    }
    return _mp4View;
}

- (UIImageView *)thumbImageView
{
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_thumbImageView];
    }
    
    return _thumbImageView;
}

- (void)setThumbImageUrl:(NSString *)thumbImageUrl
{
    _thumbImageUrl = thumbImageUrl;
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:thumbImageUrl] placeholder:nil];
}

@end
