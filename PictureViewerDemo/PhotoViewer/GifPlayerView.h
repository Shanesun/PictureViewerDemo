//
//  GifPlayerView.h
//  Bus
//
//  Created by Shane on 2017/3/9.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+TypeHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PictureViewerData : NSObject

@property (strong, nonatomic) NSString *thumbUrl;
@property (strong, nonatomic) NSString *sourceUrl;
@property (strong, nonatomic) NSString *mp4Url;
@property (assign, nonatomic) CGSize realSize;
@property (strong, nonatomic) NSString *ext;
@property (assign, nonatomic) BusImageType imageType;

@property (strong, nonatomic) id advertData;
// 处理 numb 下标
@property (assign, nonatomic) NSUInteger currentIndex;
@property (assign, nonatomic) NSUInteger totalNum;

@end

@class GifPlayerView;

@protocol GifPlayerViewDelegate <NSObject>

@optional
- (void)gifPlayerViewWillDownload:(GifPlayerView *)playerView downloadProgress:(CGFloat)progress;
- (void)gifPlayerViewEndDownload:(GifPlayerView *)playerView error:( NSError * _Nullable )error;
- (void)gifPlayerView:(GifPlayerView *)playerView downloadProgress:(CGFloat)progress;

@end

@interface GifPlayerView : UIView

@property (strong, nonatomic) NSString *thumbImageUrl;
@property (weak, nonatomic) id<GifPlayerViewDelegate> delegate;
@property (strong, nonatomic) PictureViewerData *playData;

- (void)play;
- (void)stop;

- (CGSize)orignSize;

+ (void)predownloadWithUrl:(NSString * __nullable)urlStr isMp4:(BOOL)isMp4;

@end

NS_ASSUME_NONNULL_END
