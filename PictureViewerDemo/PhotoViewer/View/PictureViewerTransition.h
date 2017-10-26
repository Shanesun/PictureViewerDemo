//
//  PictureViewerTransition.h
//  Bus
//
//  Created by Shane on 2017/5/8.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GifPlayerView.h"

@protocol PictureViewerTransitionToViewController <NSObject>

@property (weak, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) UIView *contentView;

@end

// for animation
@protocol PictureViewerTransitionDelegate <NSObject>

- (void)pictreViewerTransitionShowAnimationReady;

@end


@interface PictureViewerTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) CGRect toRect;
@property (assign, nonatomic) CGRect fromRect;
@property (strong, nonatomic) PictureViewerData *data;
@property (strong, nonatomic) UIImage *thumbImage;

@property (weak, nonatomic) id<PictureViewerTransitionDelegate> delegate;

@end

@interface PictureViewerPresentTransition : PictureViewerTransition

@end


@interface PictureViewerDismissTransition : PictureViewerTransition

@end

@interface PictureViewerInteractiveDismissTransition : PictureViewerTransition

@property (assign, nonatomic) BOOL restoreDisplay;

@end

@interface PictureViewerPercentInteractiveTransition : UIPercentDrivenInteractiveTransition

@end
