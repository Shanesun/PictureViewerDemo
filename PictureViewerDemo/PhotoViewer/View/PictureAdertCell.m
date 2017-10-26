//
//  PictureAdertCell.m
//  Bus
//
//  Created by Shane on 2017/7/31.
//  Copyright © 2017年 anzogame. All rights reserved.
//

#import "PictureAdertCell.h"
#import "QBAdvertManager.h"

@interface PictureAdertCell ()

@property (weak, nonatomic) IBOutlet UILabel *advertTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *downloadBgView;
@property (weak, nonatomic) IBOutlet UIView *advertBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *nextDynamicPicturesPromatLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promatImageView;

@end

@implementation PictureAdertCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configUI];
}

- (void)configUI
{
    self.advertTagLabel.layer.borderColor = APPCONFIG.colorConfig.color(@"L1").CGColor;
    self.advertTagLabel.layer.cornerRadius = 2;
    self.advertTagLabel.layer.borderWidth = 0.5;
    
    self.downloadBgView.backgroundColor = [UIColor colorWithHexString:@"fecd06"];
    self.downloadBgView.layer.cornerRadius = 13;
    self.downloadBgView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertClicked:)];
    [self.advertBackgroundView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self addGestureRecognizer:cellTap];
    
    // block long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
    [self addGestureRecognizer:longPress];
    
}

//- (void)setNativeAdData:(GDTNativeAdData *)nativeAdData
//{
//    if (![nativeAdData isKindOfClass:[GDTNativeAdData class]]) return;
//    
//    _nativeAdData = nativeAdData;
//    
//    self.titleLabel.text = nativeAdData.properties[GDTNativeAdDataKeyTitle];
//    self.contentLabel.text = nativeAdData.properties[GDTNativeAdDataKeyDesc];
//    NSURL *url = [NSURL URLWithString:nativeAdData.properties[GDTNativeAdDataKeyImgUrl]];
//    [self.coverImage yy_setImageWithURL:url placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
//    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
//}

//-(void)setAdModel:(QBAdertModel *)adModel {
//    if (![adModel isKindOfClass:[QBAdertModel class]]) return;
//    
//    _adModel = adModel;
//    self.titleLabel.text = adModel.title;
//    self.contentLabel.text = adModel.content;
//    NSURL *url = [NSURL URLWithString:adModel.contentUrl];
//    [self.coverImage yy_setImageWithURL:url placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
//    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
//}

-(void)setAdModel:(id)adModel {
    _adModel = adModel;
    QBAdertModel *model = nil;
    if ([adModel isKindOfClass:[WQAdvertModel class]]) {
        model = [QBAdvertManager convertWQAdData:adModel];
    }else if ([adModel isKindOfClass:[GDTNativeAdData class]]) {
        model = [QBAdvertManager convertGDTNativeAdData:adModel];
    }
    if (model == nil) return;
    self.titleLabel.text = model.title;
    self.contentLabel.text = model.content;
    NSURL *url = [NSURL URLWithString:model.contentUrl];
    [self.coverImage yy_setImageWithURL:url placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)backgroundTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if ([self.delegate respondsToSelector:@selector(pictureViewer:backgroundTap:)]) {
            [self.delegate pictureViewer:nil backgroundTap:recognizer];
        }
    }
}

- (void)advertClicked:(UITapGestureRecognizer *)recognizer
{
 // 点击广告
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (self.adClick) {
            self.adClick(self.adModel, [recognizer locationInView:self]);
        }
//        [[QBGDTAdvertManager pictureViewerAdvertManager] clickAd:self.nativeAdData];
    }
}

#pragma mark- setters and getters

- (void)setShowNextPicturesPromat:(BOOL)showNextPicturesPromat
{
    _showNextPicturesPromat = showNextPicturesPromat;
    
    if (_showNextPicturesPromat) {
        self.nextDynamicPicturesPromatLabel.hidden = NO;
        self.promatImageView.hidden = NO;
    }
    else {
        self.nextDynamicPicturesPromatLabel.hidden = YES;
        self.promatImageView.hidden = YES;
    }
}

@end
