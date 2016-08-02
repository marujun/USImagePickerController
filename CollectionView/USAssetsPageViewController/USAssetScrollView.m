//
//  USAssetScrollView.m
//  CollectionView
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetScrollView.h"

#define ScreenSize (((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width):[UIScreen mainScreen].bounds.size)

@interface USAssetScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) id asset;
@property (nonatomic, strong) UIImage *image;

@end

@implementation USAssetScrollView

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.showsVerticalScrollIndicator   = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom                    = YES;
    self.backgroundColor                = [UIColor clearColor];
    self.decelerationRate               = UIScrollViewDecelerationRateFast;
    self.delegate                       = self;
    
    [self setupViews];
}

#pragma mark - Setup

- (void)setupViews
{
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    self.imageView = imageView;
    [self addSubview:self.imageView];
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView = activityView;
        _indicatorView.center = self.center;
        
        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _indicatorView.autoresizingMask = autoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)updateDisplayImage:(UIImage *)image
{
    self.image = image;
    self.imageView.image = image;
}

- (void)initWithImage:(UIImage *)image
{
    if (!image || ![image isKindOfClass:[UIImage class]]) return;
    
    [self initZoomingViewLayoutWithImageSize:image.size];
    
    [self updateDisplayImage:image];
}

- (CGSize)imageSizeWithDimensions:(CGSize)dimensions maxPixelSize:(CGFloat)maxPixelSize
{
    CGSize imageSize = dimensions;
    if (dimensions.height > dimensions.width && dimensions.height > maxPixelSize) {
        imageSize = CGSizeMake(floorf(dimensions.width / dimensions.height * maxPixelSize), maxPixelSize);
    }
    else if (dimensions.height <= dimensions.width && dimensions.width > maxPixelSize) {
        imageSize = CGSizeMake(maxPixelSize, floorf(dimensions.height / dimensions.width * maxPixelSize));
    }
    
    return imageSize;
}

- (void)initWithALAsset:(ALAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[ALAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset] && self.image) {
        [self initWithImage:self.image];
        return;
    }
    
    self.image = nil;
    self.asset = asset;
    
    CGFloat maxPixelSize = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGSize imageSize = [self imageSizeWithDimensions:asset.defaultRepresentation.dimensions
                                        maxPixelSize:maxPixelSize*[UIScreen mainScreen].scale];
    [self initZoomingViewLayoutWithImageSize:imageSize];
    
    [self updateDisplayImage:[UIImage imageWithCGImage:asset.aspectRatioThumbnail]];
    
    __weak USAssetScrollView *weak_self = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fullImage) {
                [weak_self updateDisplayImage:fullImage];
            }
        });
    });
}

- (void)initWithPHAsset:(PHAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset] && self.image) {
        [self initWithImage:self.image];
        return;
    }
    
    self.image = nil;
    self.asset = asset;
    
    __weak USAssetScrollView *weak_self = self;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    
    CGSize imageSize = [self imageSizeWithDimensions:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                        maxPixelSize:2400.f];
    [self initZoomingViewLayoutWithImageSize:imageSize];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:imageSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (result) {
                                                    [weak_self updateDisplayImage:result];
                                                }
                                            }];
}

#pragma mark - 双击手势触发
- (void)doubleTapWithPoint:(CGPoint)point
{
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    } else {
        [self zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)setMaximumZoomScaleWithImageSize:(CGSize)imageSize
{
    CGFloat scale_screen = 1.5;
    
    float scale = imageSize.width/(ScreenSize.width*scale_screen);
    
    self.maximumZoomScale = MAX(scale, 2);
}

- (void)initZoomingViewLayoutWithImageSize:(CGSize)imageSize
{
    _imageView.bounds = [self zoomingViewBoundsForImageSize:imageSize];
    _imageView.center = CGPointMake(ScreenSize.width/2, ScreenSize.height/2);
    
    [self setMaximumZoomScaleWithImageSize:imageSize];
}

- (CGRect)zoomingViewBoundsForImageSize:(CGSize)imageSize
{
    CGSize viewSize = ScreenSize;
    
    CGSize finalSize = CGSizeZero;
    
    if (imageSize.width / imageSize.height < viewSize.width / viewSize.height) {
        finalSize.height = viewSize.height;
        finalSize.width = viewSize.height / imageSize.height * imageSize.width;
    }
    else {
        finalSize.width = viewSize.width;
        finalSize.height = viewSize.width / imageSize.width * imageSize.height;
    }
    return CGRectMake(0, 0, finalSize.width, finalSize.height);
}

#pragma mark UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *zoomView = _imageView;
    
    CGSize boundSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    
    CGFloat offsetX = (boundSize.width > contentSize.width)? (boundSize.width - contentSize.width)/2 : 0.0;
    CGFloat offsetY = (boundSize.height > contentSize.height)? (boundSize.height - contentSize.height)/2 : 0.0;
    
    zoomView.center = CGPointMake(contentSize.width/2 + offsetX, contentSize.height/2 + offsetY);
}

@end
