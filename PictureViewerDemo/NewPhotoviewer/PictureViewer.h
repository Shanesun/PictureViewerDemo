//
//  PictureViewer.h
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/10.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PictureData : NSObject

@property (strong, nonatomic) NSString *thumbUrl;
@property (strong, nonatomic) NSString *sourceUrl;
@property (strong, nonatomic) NSString *mp4Url;
@property (assign, nonatomic) CGSize realSize;
@property (strong, nonatomic) NSString *ext;
//@property (assign, nonatomic) BusImageType imageType;

//@property (strong, nonatomic) id advertData;
//// 处理 numb 下标
//@property (assign, nonatomic) NSUInteger currentIndex;
//@property (assign, nonatomic) NSUInteger totalNum;

@end

@interface PictureViewer : UIView

@property (weak ,nonatomic) PictureViewer *preViewer;
@property (weak ,nonatomic) PictureViewer *nextViewer;

@end


