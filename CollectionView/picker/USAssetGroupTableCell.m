//
//  USAssetGroupTableCell.m
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetGroupTableCell.h"

@interface USAssetGroupTableCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) PHCollection *phCollection;
@property (nonatomic, assign) PHImageRequestID requestID;


@end

@implementation USAssetGroupTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        self.imageView.bounds = CGRectMake(0, 0, kThumbnailLength, kThumbnailLength);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(100, 26, 200, 19);
    self.detailTextLabel.frame = CGRectMake(100, 55, 200, 15);
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = RGBACOLOR(225,225,225,1);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setHighlighted:selected animated:animated];
}

- (void)bind:(id)assetsGroup
{
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([assetsGroup isKindOfClass:[PHCollection class]]) {
        self.phCollection = assetsGroup;
        
        self.textLabel.text     = self.phCollection.localizedTitle;
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)self.phCollection;
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        
        //统计数量不需要排序
        NSUInteger count = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options].count;
        self.detailTextLabel.text  = [NSString stringWithFormat:@"%@", @(count)];
        
        //获取预览图需要按时间排序
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:assetCollection options:options];
        
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        
        NSInteger retinaMultiplier  = [UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(kThumbnailLength * retinaMultiplier, kThumbnailLength * retinaMultiplier);
        
        [[PHImageManager defaultManager] cancelImageRequest:_requestID];
        
        NSInteger tag = self.tag + 1;
        self.tag = tag;
        
        _requestID = [[PHImageManager defaultManager] requestImageForAsset:fetchResult.firstObject
                                                                targetSize:retinaSquare
                                                               contentMode:PHImageContentModeAspectFill
                                                                   options:requestOptions
                                                             resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                 if (self.tag == tag) {
                                                                     CGImageRef posterImage = result.CGImage;
                                                                     
                                                                     size_t height          = CGImageGetHeight(posterImage);
                                                                     float scale            = height / kThumbnailLength;
                                                                     self.imageView.image   = [UIImage imageWithCGImage:posterImage
                                                                                                                  scale:scale
                                                                                                            orientation:UIImageOrientationUp];
                                                                 }
                                                             }];
        return;
    }
    
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = self.assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
}

@end
