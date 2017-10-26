//
//  PictureViewerViewController
//  Bus
//
//  Created by Shane on 2017/3/8.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "PictureViewerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NKBaseShareObject.h"
#import "NKShareManager.h"
#import "PictureViewerCell.h"
#import "GifPlayerView.h"
#import "AppDelegate.h"
#import "WQHTTPManager+BusRecommend.h"
#import "QBAdvertManager.h"
#import "PictureAdertCell.h"
#import "UploadVideoManage.h"

@interface PictureViewerViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UIViewControllerTransitioningDelegate, SSZoomVieweControllerDelegate, PictureViewerTransitionDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) UIView *contentView;

@property (weak, nonatomic) IBOutlet UICollectionView        *collectionView;
@property (weak, nonatomic) IBOutlet UIView                  *toolBar;
@property (weak, nonatomic) IBOutlet UILabel                 *pageLabel;
@property (weak, nonatomic) IBOutlet UIButton                *downloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downInd;
@property (weak, nonatomic) IBOutlet UIButton                *shareButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *shareInd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint      *shareButtonWidthLC;

@property (strong, nonatomic) NSURLSessionDataTask *downImageTask;
@property (strong, nonatomic) NSIndexPath          *currentIndexPath;
@property (assign, nonatomic) int                  totalPictures;
@property (assign, nonatomic) BOOL                 showStateBar;
@property (assign, nonatomic) BOOL                 shareAlertDisplayed;
@property (assign, nonatomic) BOOL                 isShared;

// 控制转场动画
@property (strong, nonatomic) UIViewController                     *sourceVC;
@property (assign, nonatomic) BOOL                                 interrating;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactionController;// 交互转场动画
@property (strong, nonatomic) PictureViewerInteractiveDismissTransition *interactiveDismissTransition;

// 滑动退出
@property (strong, nonatomic) UIPanGestureRecognizer *panToExit;

@property (strong, nonatomic) QBAdvertManager          *picAdManager;
@end

@implementation PictureViewerViewController

- (instancetype)initWithSelectIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _currentIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        self.backgroundView.alpha = 0;
        self.showStateBar = YES;
        
    }
    
    return self;
}

- (void)configUI
{
    // 分享
    if (APPCONFIG.ucmConfig.boolean(@"f_verify_thirdShare") && self.hidenShareButton == NO) {
        self.shareButtonWidthLC.constant = 48;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareButtonClicked:)];
        [self.view addGestureRecognizer:longPress];
    }
    else{
        self.shareButtonWidthLC.constant = 0;
    }
    
    self.panToExit = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInteractRecognizer:)];
    [self.view addGestureRecognizer:self.panToExit];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[PictureViewerCell class] forCellWithReuseIdentifier:@"PictureViewerCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PictureAdertCell" bundle:nil] forCellWithReuseIdentifier:@"advertCell"];
    
    self.collectionView.hidden = YES;
    self.toolBar.hidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configUI];
    
    // 在大图时 保活广告出现，退出大图模式
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidenWhenAdvertAppear)
                                                 name:@"liqingzhao_baohuoguanggaochuxian_xiaoshi"
                                               object:nil];
    
    [self canAutoRotation:YES];
}

- (void)hidenWhenAdvertAppear{
    [self dismissWithAnimation:NO];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    PictureViewerCell *currentCell = (PictureViewerCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    if (![currentCell isKindOfClass:[PictureViewerCell class]]) return;
    
    [currentCell.pictureViewer.gifPlayerView play];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    PictureViewerCell *cell = (PictureViewerCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    if (![cell isKindOfClass:[PictureViewerCell class]]) return;
    
    [cell.pictureViewer.gifPlayerView stop];
}

- (void)dealloc
{
    NSLog(@"%@",self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stepNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark- public methods
- (void)show
{
    self.modalPresentationStyle = UIModalPresentationCustom;
    // 只有设置了YES再modelPresent在非fullscreen才，status bar才能修改。
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    self.transitioningDelegate = self;
    
    if ([self.delegate respondsToSelector:@selector(pickerViewerWillAppear:currentIndex:)]) {
        [self.delegate pickerViewerWillAppear:self currentIndex:self.currentIndexPath.row];
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:^{
        
        self.showStateBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        self.toolBar.hidden = NO;
        self.collectionView.hidden = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        if (self.currentIndexPath.section < [self.collectionView numberOfSections] && self.currentIndexPath.row < [self.collectionView numberOfItemsInSection:self.currentIndexPath.section]) {
            [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        
        
        if ([self.delegate respondsToSelector:@selector(pickerViewerDidAppear:currentIndex:)]) {
            [self.delegate pickerViewerDidAppear:self currentIndex:self.currentIndexPath.row];
        }
        [self stepNotifications];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self didAppearPictureViewerWithShowIndexPath:_currentIndexPath];
        }];
        self.picAdManager = [QBAdvertManager busPictureManager:self];
//        [QBGDTAdvertManager pictureViewerAdvertManager:self];
    }];
}

- (void)reloadData
{
    [self updatePageIndex];
    
    [self.collectionView reloadData];
}

#pragma mark- animation
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.sourceVC = source;
    presented.view.frame = source.view.bounds;
    
    CGRect cellRect = [self.delegate pickerViewer:self originImageRectOfPhotoDisplayIndexPath:self.currentIndexPath toVC:presented];
    PictureViewerData *data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:self.currentIndexPath];
    UIImage *thumbImage = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:data.thumbUrl]]];
    
    PictureViewerPresentTransition *presentTransition = [PictureViewerPresentTransition new];
    presentTransition.fromRect = cellRect;
    presentTransition.data = data;
    presentTransition.thumbImage = thumbImage;
    presentTransition.delegate = self;
    
    return presentTransition;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    CGRect cellRect = [self.delegate pickerViewer:self originImageRectOfPhotoDisplayIndexPath:self.currentIndexPath toVC:self.sourceVC];
    PictureViewerData *data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:self.currentIndexPath];
    UIImage *thumbImage = [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:data.thumbUrl]]];
    
    if (self.interactionController) {
        self.interactiveDismissTransition = [PictureViewerInteractiveDismissTransition new];
        
        return self.interactiveDismissTransition;
    }
    else{
        PictureViewerDismissTransition *dismissTransition = [PictureViewerDismissTransition new];
        dismissTransition.toRect = cellRect;
        dismissTransition.data = data;
        dismissTransition.thumbImage = thumbImage;
        
        return dismissTransition;
    }
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactionController;
}

- (void)panInteractRecognizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.interrating = YES;
            self.interactionController = [UIPercentDrivenInteractiveTransition new];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat progress = [self progressOfPanRecognizer:recognizer];
            if (progress < 0) {
                progress = 0;
            }
            [self.interactionController updateInteractiveTransition:progress];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            self.interrating = NO;
            if ([recognizer velocityInView:self.view].y > 0) {
                [self.interactionController finishInteractiveTransition];
                [self dismissedWithPullDownExit];
            }
            else {
                CGFloat progress = [self progressOfPanRecognizer:recognizer];
                CGFloat speed = [recognizer velocityInView:self.view].y;
                self.interactionController.completionSpeed = speed / (progress * self.view.height);
                [self.interactionController cancelInteractiveTransition];
                [UploadVideoManage uploadViewForceHidden];
                self.interactiveDismissTransition.restoreDisplay = YES;
            }
            
            self.interactionController = nil;
            
            break;
        }
        default:
            [self.interactionController cancelInteractiveTransition];
            self.interactiveDismissTransition.restoreDisplay = YES;
            self.interactionController = nil;
            break;
    }
}

- (CGFloat)progressOfPanRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGFloat percentage = translation.y / CGRectGetHeight(recognizer.view.bounds);
    
    return percentage;
}

#pragma mark- private methods
- (void)canAutoRotation:(BOOL)autoRotation {
    [(AppDelegate *)[UIApplication sharedApplication].delegate setCanAutoRotation:autoRotation];
}

- (void)tapBackground
{
    if ([UIDevice currentDevice].orientation != UIInterfaceOrientationPortrait) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissWithAnimation:YES];
        });
    }
    else{
        [self dismissWithAnimation:YES];
    }
}

- (void)dismissWithAnimation:(BOOL)animation
{
    self.showStateBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self canAutoRotation:NO];
    
    if ([self.delegate respondsToSelector:@selector(pickerViewerWillDisAppear:finishIndex:)]) {
        [self.delegate pickerViewerWillDisAppear:self finishIndex:self.currentIndexPath.row];
    }
    
    [self dismissViewControllerAnimated:animation completion:^{
        self.toolBar.hidden = YES;
        [self.downImageTask cancel];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if ([self.delegate respondsToSelector:@selector(pickerViewerDidDisAppear:finishIndex:)]) {
            [self.delegate pickerViewerDidDisAppear:self finishIndex:self.currentIndexPath.row];
        }
    }];
}

- (void)dismissedWithPullDownExit
{
    self.showStateBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self canAutoRotation:NO];
    
    if ([self.delegate respondsToSelector:@selector(pickerViewerWillDisAppear:finishIndex:)]) {
        [self.delegate pickerViewerWillDisAppear:self finishIndex:self.currentIndexPath.row];
    }
    
    self.toolBar.hidden = YES;
    [self.downImageTask cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.delegate respondsToSelector:@selector(pickerViewerDidDisAppear:finishIndex:)]) {
        [self.delegate pickerViewerDidDisAppear:self finishIndex:self.currentIndexPath.row];
    }
}

- (void)didAppearPictureViewerWithShowIndexPath:(NSIndexPath *)didShowIndexpath
{
    self.currentIndexPath = didShowIndexpath;
    
    // 1 开始 当前界面的gif/mp4 播放
    PictureViewerCell *currentCell = (PictureViewerCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    if (![currentCell isKindOfClass:[PictureViewerCell class]]){
        self.toolBar.hidden = YES;
        return;
    }
    else {
        self.toolBar.hidden = NO;
    }
    
    [currentCell didShow];
    
    // 非wifi下不进行预加载
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        return;
    }
    // 2 开始预下载 前后2张 图片/mp4
    [self predownloadImageAndMp4WithAfter:YES];
    [self predownloadImageAndMp4WithAfter:NO];
}

- (void)predownloadImageAndMp4WithAfter:(BOOL)isAfter
{
    NSIndexPath *indexPath = nil;
    PictureViewerData *data = nil;
    if (isAfter) {
        if ((int)self.currentIndexPath.row + 1 >= [self.delegate pickerViewer:self numOfPhotosWithSection:self.currentIndexPath.section]) {
            if ([self.delegate respondsToSelector:@selector(sectionOfPhotosPickerViewer:)] && (self.currentIndexPath.section + 1) < [self.delegate sectionOfPhotosPickerViewer:self]) {
                indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentIndexPath.section + 1];
            }
            else{
                return;
            }
        }
        else {
            indexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.row + 1 inSection:self.currentIndexPath.section];
        }
    }
    else{
        if ((int)self.currentIndexPath.row - 1 <  0) {
            if ([self.delegate respondsToSelector:@selector(sectionOfPhotosPickerViewer:)] && (self.currentIndexPath.section - 1) >= 0) {
                indexPath = [NSIndexPath indexPathForRow:[self.delegate pickerViewer:self numOfPhotosWithSection:(self.currentIndexPath.section - 1)]-1 inSection:(self.currentIndexPath.section - 1)];
            }
            else{
                return;
            }
        }
        else {
            indexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.row - 1 inSection:self.currentIndexPath.section];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerViewer:pickerViewerDataWithIndexPath:)]) {
        data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:indexPath];
    }
    
    if ([data.mp4Url isKindOfClass:[NSString class]] && data.mp4Url.length > 0) {
        [GifPlayerView predownloadWithUrl:data.mp4Url isMp4:YES];
    }
    else{
        [GifPlayerView predownloadWithUrl:data.sourceUrl isMp4:NO];
    }
}

-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    if (image1 == nil || image2 == nil) {
        return NO;
    }
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqualToData:data2];
}

#pragma mark animation

#pragma mark- collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(sectionOfPhotosPickerViewer:)]) {
        return [self.delegate sectionOfPhotosPickerViewer:self];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate pickerViewer:self numOfPhotosWithSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PictureViewerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PictureViewerCell" forIndexPath:indexPath];
    
    PictureViewerData *data = nil;
    if ([self.delegate respondsToSelector:@selector(pickerViewer:pickerViewerDataWithIndexPath:)]) {
        data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:indexPath];
    }
    if (data.advertData) {
        PictureAdertCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"advertCell" forIndexPath:indexPath];
        cell.adModel = data.advertData;
//        cell.nativeAdData = data.advertData;
        cell.delegate = self;
        // 存在下一个推荐图集时 才会显示 左滑显示下一图集提示文案
        if ([self.delegate respondsToSelector:@selector(sectionOfPhotosPickerViewer:)] && indexPath.section <= ((int)[self.delegate sectionOfPhotosPickerViewer:self]-2)) {
            cell.showNextPicturesPromat = YES;
        }
        else {
            cell.showNextPicturesPromat = NO;
        }
        if (self.adCellShow) {
            self.adCellShow(data.advertData, cell);
        }
//        [[QBGDTAdvertManager pictureViewerAdvertManager] attachAd:data.advertData toView:cell];
        cell.adClick = self.adClick;
        return cell;
    }
    else{
        if (![self.childViewControllers containsObject:cell.pictureViewer]) {
            [self addChildViewController:cell.pictureViewer];
        }
        cell.data = data;
        cell.pictureViewer.delegate = self;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(PictureViewerCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell && [cell isKindOfClass:[PictureViewerCell class]]) {
        // 1 停止 不在当前界面的gif/mp4 播放
        [cell.pictureViewer.gifPlayerView stop];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *pageIndex = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    if ([self.currentIndexPath isEqual:pageIndex]) {
        return;
    }
    
    NSIndexPath *didShowIndexPath = pageIndex;
    [self didAppearPictureViewerWithShowIndexPath:didShowIndexPath];
}

#pragma mark- picture viewer transition delegate
- (void)pictreViewerTransitionShowAnimationReady
{
    if ([self.delegate respondsToSelector:@selector(pickerViewerShowAnimationReady:currentIndex:)]) {
        [self.delegate pickerViewerShowAnimationReady:self currentIndex:self.currentIndexPath.row];
    }
}

#pragma mark-
- (void)pictureViewer:(PictureViewerViewController *)viewer backgroundTap:(UITapGestureRecognizer *)backgroundTap
{
    [self tapBackground];
}

#pragma mark- setters and getters
- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath
{
    _currentIndexPath = currentIndexPath;
    
    [self updatePageIndex];
}

- (void)updatePageIndex
{
    NSUInteger count = [self.delegate pickerViewer:self numOfPhotosWithSection:self.currentIndexPath.section];
    if (count > 0) {
        PictureViewerData *data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:_currentIndexPath.section]];
        if (data.advertData == nil) {
            self.pageLabel.text = [[NSString alloc] initWithFormat:@"%d/%d",(int)(self.currentIndexPath.row + 1),(int)count];
        }
        else {
            self.pageLabel.text = [[NSString alloc] initWithFormat:@"%d/%d",(int)(self.currentIndexPath.row + 1),(int)count-1];        }
    }
}

- (int)totalPictures
{
    if (_totalPictures == 0) {
        return (int)[self.collectionView numberOfItemsInSection:0];
    }
    else{
        return _totalPictures;
    }
}
#pragma mark- IBAction
- (IBAction)shareButtonClicked:(id)sender
{
    if (self.shareAlertDisplayed) {
        return;
    }
    
    PictureViewerData *data = [self getCurrentData];
    self.shareAlertDisplayed = YES;
    
    ShareAlert *shareSheetView = [ShareAlert show];
    [shareSheetView showExtBTN:@[]];
    if ([data.ext.lowercaseString isEqualToString:@"gif"]) {
        shareSheetView.titleLabel.text = @"分享动图";
    }
    else{
        shareSheetView.titleLabel.text = @"分享图片";
    }
    
    shareSheetView.alertDismissed = ^{
        [self shareFinish:NO type:nil];
    };
    
    __weak __typeof(self)weakSelf = self;
    [shareSheetView setShareWtihType:^(int type) {
        self.shareInd.hidden = NO;
        [self.shareInd startAnimating];
        self.shareButton.hidden = YES;
        
        NSString *url = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.kuaishangche.cc/",self.shareData.id];
        NKShareType shareType = NKShareTypeLink;
        // 以表情分享
        if (type == WQSharePlatformQQFriend || type == WQSharePlatformWechatSession) {
            shareType = NKShareTypeEmotion;
        }// 以链接分享
        else{
            shareType = NKShareTypeLink;
        }
        NSString *content = self.shareData.content;
        NSString *tilte = nil;
        if (self.shareData.albums.count > 0) {
            tilte = [[NSString alloc] initWithFormat:@"来不及解释了，老司机们在[%@]开车啦~",[[self.shareData.albums firstObject] title]];
        }
        else{
            tilte = NSLocalizedString(@"gobus", nil);
        }
        
        [NKBaseShareObject shareObjectWithTitle:tilte
                                        content:content
                                       shareUrl:url
                                       shareImg:data.sourceUrl
                                     thumbImage:data.thumbUrl
                                        extInfo:data.ext
                                      shareType:shareType
                                  sharePlatform:type
                                    finishBlock:^(BOOL isSuccess, id type) {
                                        [weakSelf shareFinish:isSuccess type:type];
                                    }];
    }];
}

- (void)shareFinish:(BOOL)isSuccess type:(id)type
{
    self.shareAlertDisplayed = NO;
    self.shareInd.hidden = YES;
    self.shareButton.hidden = NO;
    if ([type isEqualToString:@"downfail"]) {
        [SVProgressHUD showInfoWithStatus:@"分享资源获取失败，请稍后重试"];
    }
    if (isSuccess) {
        [WQHTTPManager report_shhareReportFrom:type is_share:[NSString stringWithFormat:@"%d",isSuccess] target_id:self.shareData.id target_type:@"1" success:nil failure:nil];
        
        int count = [self.shareData.share_count intValue];
        if (isSuccess) {
            if (isnan(count) || isinf(count)) {
                count = 0;
            }
            self.shareData.share_count = [NSString stringWithFormat:@"%d",count +1];
        }
        self.isShared = YES;
    }
    
}

#pragma mark toolbar
- (IBAction)downButtonClicked:(UIButton *)sender
{
    self.downloadButton.hidden = YES;
    [self.downInd startAnimating];
    
    PictureViewerData *data = nil;
    if ([self.delegate respondsToSelector:@selector(pickerViewer:pickerViewerDataWithIndexPath:)]) {
        data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:self.currentIndexPath];
    }
    
    if (data == nil || data.sourceUrl == nil) {
        return;
    }
    
    NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:data.sourceUrl]];
    NSData *cacheImageData = [[YYImageCache sharedCache] getImageDataForKey:cacheKey];
    
    if (cacheImageData == nil) {
        self.downImageTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:data.sourceUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                if (error.code != NSURLErrorCancelled) {
                    [SVProgressHUD showSuccessWithStatus:@"下载失败，请稍后重试"];
                }
                self.downInd.hidden = YES;
                self.downloadButton.hidden = NO;
                
                return;
            }
            // 保存到缓存中
            [[YYImageCache sharedCache] setImage:nil imageData:data forKey:cacheKey withType:YYImageCacheTypeAll];
            
            [self saveImageDataToAlbum:data];
        }];
        [self.downImageTask resume];
    }
    else{
        [self saveImageDataToAlbum:cacheImageData];
    }
}

- (PictureViewerData *)getCurrentData
{
    PictureViewerData *data = nil;
    if ([self.delegate respondsToSelector:@selector(pickerViewer:pickerViewerDataWithIndexPath:)]) {
        data = [self.delegate pickerViewer:self pickerViewerDataWithIndexPath:self.currentIndexPath];
    }
    if (data == nil || data.sourceUrl == nil) {
        return nil;
    }
    else{
        return data;
    }
}

- (void)saveImageDataToAlbum:(NSData *)imageData
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        [self saveResultWithError:error];
    }];
}

- (void)saveResultWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
            [SVProgressHUD showSuccessWithStatus:@"已保存至手机相册"];
        }else {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == ALAuthorizationStatusDenied || author == ALAuthorizationStatusRestricted) {
                [SVProgressHUD showInfoWithStatus:@"保存失败请开启访问权限"];
            }else {
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
            }
        }
        
        [self.downInd stopAnimating];
        self.downloadButton.hidden = NO;
    });
}

#pragma mark- 旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{   // 取出 cell 全屏，单独做动画
    PictureViewerCell *cell = (PictureViewerCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    UIView *tmpView = nil;
    if ([cell isKindOfClass:[PictureViewerCell class]]) {
        tmpView = cell.pictureViewer.view;
    }
    else if ([cell isKindOfClass:[PictureAdertCell class]]) {
        tmpView = cell.contentView;
    }
    else {
        return;
    }
    
    [self.view addSubview:tmpView];
    [tmpView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Update scroll position during rotation animation
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize = size;
        [self.collectionView.collectionViewLayout invalidateLayout];
        self.collectionView.contentOffset = CGPointMake(self.currentIndexPath.row*size.width, 0);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Whatever you want to do when the rotation animation is done
        [cell addSubview:tmpView];
        [tmpView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(tmpView.superview);
        }];
        
        // 图片横屏滑动退出存在显示问题，这里在横屏时进行禁用。
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait) {
            self.panToExit.enabled = YES;
        }
        else{
            self.panToExit.enabled = NO;
        }
    }];
}

#pragma mark - StatusBar
- (BOOL)prefersStatusBarHidden {
    return !self.showStateBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

@end
