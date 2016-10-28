//
//  ImagePreviewController.m
//  Openlab
//
//  Created by admin on 16/8/24.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "ImagePreviewController.h"
#import <UIView+Layout.h>
#import "TZImagePickerController.h"
@interface ImagePreviewController()<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    CGFloat _aspectRatio;
    UIView *_naviBar;
    UIButton *_backButton;
    BOOL   isHiddenNav;
}
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIView *imageContainerView;
@property(nonatomic,strong) UIImageView *imageView;
@end

@implementation ImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.view.backgroundColor = [UIColor blackColor];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 0, self.view.tz_width, self.view.tz_height);
    _scrollView.bouncesZoom = YES;
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.multipleTouchEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.alwaysBounceVertical = NO;
    [self.view addSubview:_scrollView];
    
    _imageContainerView = [[UIView alloc] init];
    _imageContainerView.clipsToBounds = YES;
    [_scrollView addSubview:_imageContainerView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    _imageView.clipsToBounds = YES;
    [_imageContainerView addSubview:_imageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self.view addGestureRecognizer:tap2];
    
    [self configCustomNaviBar];
    
    
    [_scrollView setZoomScale:1.0 animated:NO];
    self.imageView.image = _photo;
    
    [self resizeSubviews];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}
- (void)configCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, 64)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    _naviBar.alpha = 0.7;
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 15, 44, 44)];
    [_backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}
-(void)back{
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)resizeSubviews {
    _imageContainerView.tz_origin = CGPointZero;
    _imageContainerView.tz_width = self.view.tz_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.view.tz_height / self.view.tz_width) {
        _imageContainerView.tz_height = floor(image.size.height / (image.size.width / self.view.tz_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.view.tz_width;
        if (height < 1 || isnan(height)) height = self.view.tz_height;
        height = floor(height);
        _imageContainerView.tz_height = height;
        _imageContainerView.center = self.view.center;
    }
    if (_imageContainerView.tz_height > self.view.tz_height ) {
        _imageContainerView.tz_height = self.view.tz_height;
    }
    _scrollView.contentSize = CGSizeMake(self.view.tz_width, MAX(_imageContainerView.tz_height, self.view.tz_height));
    [_scrollView scrollRectToVisible:self.view.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.tz_height <= self.view.tz_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.view.frame.size.width / newZoomScale;
        CGFloat ysize = self.view.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    isHiddenNav=!isHiddenNav;
    _naviBar.hidden=isHiddenNav;
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.tz_width > scrollView.contentSize.width) ? (scrollView.tz_width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.tz_height > scrollView.contentSize.height) ? (scrollView.tz_height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
