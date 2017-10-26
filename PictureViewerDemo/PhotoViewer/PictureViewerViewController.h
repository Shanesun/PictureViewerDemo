//
//  PictureViewerViewController
//  Bus
//
//  Created by Shane on 2017/3/8.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSZoomVieweController.h"
#import "WQRecommendListModel.h"
#import "PictureViewerTransition.h"

@class PictureViewerViewController;

@protocol PictureViewerDataSource <NSObject>

- (PictureViewerData *)pickerViewer:(PictureViewerViewController *)pictureViewerViewController pickerViewerDataWithIndexPath:(NSIndexPath*)indexPath;
- (CGRect)pickerViewer:(PictureViewerViewController *)pictureViewerViewController originImageRectOfPhotoDisplayIndexPath:(NSIndexPath *)indexPath toVC:(UIViewController *)toVC;
- (NSInteger)pickerViewer:(PictureViewerViewController *)pictureViewerViewController numOfPhotosWithSection:(NSInteger)section;

@optional
- (NSInteger)sectionOfPhotosPickerViewer:(PictureViewerViewController *)pictureViewerViewController;

- (void)pickerViewer:(PictureViewerViewController *)pictureViewerViewController didShowPictureIndex:(NSInteger)index;

- (void)pickerViewerWillAppear:(PictureViewerViewController *)pictureViewerViewController currentIndex:(NSInteger)currentIndex;
- (void)pickerViewerDidAppear:(PictureViewerViewController *)pictureViewerViewController currentIndex:(NSInteger)currentIndex;

- (void)pickerViewerWillDisAppear:(PictureViewerViewController *)pictureViewerViewController finishIndex:(NSInteger)finishIndex;
- (void)pickerViewerDidDisAppear:(PictureViewerViewController *)pictureViewerViewController finishIndex:(NSInteger)finishIndex;

// just for show animation
- (void)pickerViewerShowAnimationReady:(PictureViewerViewController *)pictureViewerViewController currentIndex:(NSInteger)currentIndex;

@end

@interface PictureViewerViewController : UIViewController

@property (strong, nonatomic) WQRecommendListModelData *shareData;
@property (assign, nonatomic) BOOL hidenShareButton;
@property (weak, nonatomic) id<PictureViewerDataSource> delegate;
@property (nonatomic, strong) void (^adCellShow)(id model, UIView *view);
@property (nonatomic, strong) void (^adClick)(id model, CGPoint point);

- (instancetype)initWithSelectIndex:(NSInteger)index;
- (void)reloadData;
- (void)show;

@end
