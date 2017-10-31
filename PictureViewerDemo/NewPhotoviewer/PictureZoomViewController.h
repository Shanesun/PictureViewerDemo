//
//  PictureZoomViewController.h
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/25.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureViewerViewController.h"

typedef NS_ENUM(NSUInteger, PictureShowModel) {
    PictureShowModelWidthFirst,
    PictureShowModelFillFit,
};

@interface PictureZoomViewController : UIViewController

@property (assign, nonatomic) PictureShowModel pictureShowModel;
@property (strong, nonatomic) PictureData *data;

@end
