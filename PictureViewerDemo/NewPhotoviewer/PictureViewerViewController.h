//
//  PictureViewerViewController.h
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/10.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureViewer.h"

@class PictureViewerViewController;

@protocol PictureViewerDelegate

- (NSUInteger)numberOfPicturesWithPictureViewerViewController:(PictureViewerViewController *)pictureViewer;
- (PictureData *)pictureViewerViewController:(PictureViewerViewController *)pictureViewer;

@optional
- (CGRect)pictureWithPictureViewerViewController:(PictureViewerViewController *)pictureViewer rectOfOriginalPictureIndex:(NSUInteger)index;

@end

@interface PictureViewerViewController : UIViewController

- (instancetype)initWithIndex:(NSUInteger)index delegate:(id<PictureViewerDelegate>)delegate;

@end
