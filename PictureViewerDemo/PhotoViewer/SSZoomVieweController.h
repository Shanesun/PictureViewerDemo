//
//  SSZoomVieweController
//  Bus
//
//  Created by Shane on 2017/3/9.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifPlayerView.h"
#import "ZoomScrollView.h"

@class SSZoomVieweController;

@protocol SSZoomViewer <NSObject>

@end

@protocol SSZoomVieweControllerDelegate <NSObject>

- (void)pictureViewer:(SSZoomVieweController *)viewer backgroundTap:(UITapGestureRecognizer *)backgroundTap;

@end

@interface SSZoomVieweController : UIViewController

@property (strong, nonatomic) PictureViewerData *playData;
@property (strong, nonatomic) GifPlayerView *gifPlayerView;
@property (weak, nonatomic)   id<SSZoomVieweControllerDelegate> delegate;

@property (strong, nonatomic) ZoomScrollView *scrollView;

@end
