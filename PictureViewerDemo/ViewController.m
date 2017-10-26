//
//  ViewController.m
//  PictureViewerDemo
//
//  Created by Shane Li on 2017/10/10.
//  Copyright © 2017年 Shane Li. All rights reserved.
//

#import "ViewController.h"
#import "PictureViewerViewController.h"

@interface ViewController () <PictureViewerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)openPictureViewer:(UIButton *)sender {
    PictureViewerViewController *picVC = [[PictureViewerViewController alloc] initWithIndex:0 delegate:self];
    [self presentViewController:picVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPicturesWithPictureViewerViewController:(PictureViewerViewController *)pictureViewer {
    return 10;
}

- (PictureData *)pictureViewerViewController:(PictureViewerViewController *)pictureViewer {
    return nil;
}


@end
