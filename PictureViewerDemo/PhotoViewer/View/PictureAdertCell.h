//
//  PictureAdertCell.h
//  Bus
//
//  Created by Shane on 2017/7/31.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBGDTAdvertManager.h"
#import "SSZoomVieweController.h"

@interface PictureAdertCell : UICollectionViewCell

@property (assign, nonatomic) BOOL showNextPicturesPromat; // 控制是否显示 左滑浏览相关图集 提示语
@property (weak, nonatomic) id<SSZoomVieweControllerDelegate> delegate;
//@property (strong, nonatomic) GDTNativeAdData *nativeAdData;
@property (weak, nonatomic) id adModel;
@property (nonatomic, strong) void (^adClick)(id model, CGPoint point);

@end
