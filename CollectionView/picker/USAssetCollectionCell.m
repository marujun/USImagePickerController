//
//  USAssetCollectionCell.m
//  CollectionView
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetCollectionCell.h"

@interface USAssetCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property (nonatomic, strong) ALAsset *alAsset;

@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, assign) PHImageRequestID requestID;

@property (nonatomic, copy) NSString *identifier;

@end

@implementation USAssetCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)bind:(id)asset selected:(BOOL)selected
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        self.phAsset = asset;
    } else {
        self.alAsset = asset;
    }
    
    if(self.phAsset) {
        
        NSInteger tag = self.tag + 1;
        self.tag = tag;
        
        [self.imageManager cancelImageRequest:self.requestID];
        
        self.requestID = [self.imageManager requestImageForAsset:self.phAsset
                                                      targetSize:_thumbnailTargetSize
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:_thumbnailRequestOptions
                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       if (self.tag == tag) {
                                                           [self.imageButton setImage:result forState:UIControlStateNormal];
                                                       }
                                                   }];
    } else {
        [self.imageButton setImage:[UIImage imageWithCGImage:self.alAsset.thumbnail] forState:UIControlStateNormal];
    }
    
    self.identifier = [asset localIdentifier];
}

- (IBAction)imageButtonAction:(UIButton *)sender
{
    
}

@end
