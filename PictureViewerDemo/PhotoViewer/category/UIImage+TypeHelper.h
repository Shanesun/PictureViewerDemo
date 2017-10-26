//
//  UIImage+TypeHelper.h
//  Bus
//
//  Created by Shane on 2017/3/24.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBusLongPictureHWScale 2/1
#define kBusWidePictureHWScale 1/5

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BusImageType) {
    BusImageTypeNormal,
    BusImageTypeLong,
    BusImageTypeWide
};

@interface UIImage (TypeHelper)

- (BusImageType)imageType;

+ (BusImageType)imageTypeWithSize:(CGSize)realSize;

@end

NS_ASSUME_NONNULL_END
