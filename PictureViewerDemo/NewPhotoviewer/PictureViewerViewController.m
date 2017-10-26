//
//  PictureViewerViewController.m
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/10.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import "PictureViewerViewController.h"

@interface PictureViewerViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) id<PictureViewerDelegate> delegate;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (assign, nonatomic) NSUInteger totalPictures;

@property (strong, nonatomic) PictureViewer *currentViewer;
@property (strong, nonatomic) PictureViewer *tmpView1;
@property (strong, nonatomic) PictureViewer *tmpView2;
@property (strong, nonatomic) PictureViewer *tmpView3;

@end

@implementation PictureViewerViewController
- (instancetype)initWithIndex:(NSUInteger)index delegate:(id<PictureViewerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.currentIndex = index;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    if (@available(iOS 11.0, *)) {
//        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
    } else {
        // Fallback on earlier versions
    }
    
    [self stepScrollView];
    [self stepViewers];
}

- (void)dealloc {
    self.tmpView2.preViewer.preViewer.nextViewer = nil;
    self.tmpView2.preViewer.preViewer = nil;
    self.tmpView2.nextViewer.nextViewer = nil;
    self.tmpView2.nextViewer = nil;
}

- (void)stepScrollView {
    self.totalPictures = [self.delegate numberOfPicturesWithPictureViewerViewController:self];
    CGFloat contentWidth = self.view.frame.size.width * self.totalPictures;
    
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.view.frame.size.height);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
}

- (void)stepViewers {
    self.tmpView1 = [PictureViewer new];
    self.tmpView1.backgroundColor = [UIColor redColor];

    self.tmpView2 = [PictureViewer new];
    self.tmpView2.backgroundColor = [UIColor greenColor];
    
    self.tmpView3 = [PictureViewer new];
    self.tmpView3.backgroundColor = [UIColor blueColor];
    
    self.tmpView2.preViewer = self.tmpView1;
    self.tmpView2.nextViewer = self.tmpView3;
    
    self.tmpView3.preViewer = self.tmpView2;
    self.tmpView1.nextViewer = self.tmpView2;
    
    self.currentViewer = self.tmpView2;
}

#pragma mark- private methods
- (void)updateCurrentViewr {
    int tmpCurrtentIndex  = (int)self.scrollView.contentOffset.x / self.view.frame.size.width;
    if (tmpCurrtentIndex == self.currentIndex) return;
    // 向右
    if (tmpCurrtentIndex > self.currentIndex) {
        // 移动指针
        self.currentViewer.nextViewer.nextViewer = self.currentViewer.preViewer;
        self.currentViewer.nextViewer.preViewer = self.currentViewer;
        
        self.currentViewer.preViewer.nextViewer = nil;
        self.currentViewer.preViewer = nil;
        
        // 设置当前指针
        self.currentIndex = tmpCurrtentIndex;
        self.currentViewer = self.currentViewer.nextViewer;
    }// 向左
    else {
        self.currentViewer.preViewer.preViewer = self.currentViewer.nextViewer;
        self.currentViewer.nextViewer.nextViewer = self.currentViewer.preViewer;
        
        self.currentViewer.nextViewer.preViewer = nil;
        self.currentViewer.nextViewer = nil;
        
        self.currentIndex = tmpCurrtentIndex;
        self.currentViewer = self.currentViewer.preViewer;
    }
}

#pragma mark- scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"----did scroll %f ---- ", scrollView.contentOffset.x);
    [self updateCurrentViewr];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
//        [self updateCurrentViewr];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self updateCurrentViewr];
}

#pragma mark- setters and getters
- (void)setCurrentViewer:(PictureViewer *)currentViewer {
    _currentViewer = currentViewer;
    // current
    if (_currentViewer.superview == nil) {
        [self.scrollView addSubview:_currentViewer];
        _currentViewer.frame = CGRectMake(self.currentIndex * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    // pre
    if (self.currentIndex > 0) {
        if (_currentViewer.preViewer.superview == nil) {
            [self.scrollView addSubview:_currentViewer.preViewer];
        }
        _currentViewer.preViewer.frame = CGRectMake((self.currentIndex-1)*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    // next
    if (self.currentIndex < self.totalPictures-1) {
        if (_currentViewer.nextViewer.superview == nil) {
            [self.scrollView addSubview:_currentViewer.nextViewer];
        }
        _currentViewer.nextViewer.frame = CGRectMake((self.currentIndex+1)*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

@end
