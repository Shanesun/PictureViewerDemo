//
//  UIImage+TypeHelper.m
//  Bus
//
//  Created by Shane on 2017/3/24.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "UIImage+TypeHelper.h"

@implementation UIImage (TypeHelper)

- (BusImageType)imageType
{
    return [UIImage imageTypeWithSize:self.size];
}

+ (BusImageType)imageTypeWithSize:(CGSize)realSize
{
    // 高/宽比 > 2/1 定义为长图
    if (realSize.height/realSize.width > kBusLongPictureHWScale) {
        return BusImageTypeLong;
    }
    
    if (realSize.height/realSize.width < kBusWidePictureHWScale) {
        return BusImageTypeWide;
    }
    return BusImageTypeNormal;
}

@end
