//
//  PictureViewerCell.h
//  Bus
//
//  Created by Shane on 2017/3/14.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSZoomVieweController.h"
#import "GifPlayerView.h"

@interface PictureViewerCell : UICollectionViewCell

@property (strong, nonatomic) SSZoomVieweController *pictureViewer;
@property (strong, nonatomic) PictureViewerData *data;

- (void)didShow;

@end
