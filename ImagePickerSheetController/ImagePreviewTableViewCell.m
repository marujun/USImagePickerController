//
//  ImagePreviewTableViewCell.m
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImagePreviewTableViewCell.h"

@interface ImagePreviewTableViewCell ()

@end

@implementation ImagePreviewTableViewCell

- (void)setCollectionView:(ImagePickerCollectionView *)collectionView
{
    if (_collectionView) {
        [_collectionView removeFromSuperview];
    }
    
    _collectionView = collectionView;
    
    [self addSubview:_collectionView];
}

- (void)prepareForReuse
{
    self.collectionView = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_collectionView) {
        _collectionView.frame = CGRectMake(-self.bounds.size.width, CGRectGetMinY(self.bounds), self.bounds.size.width*3, self.bounds.size.height);
        _collectionView.contentInset = UIEdgeInsetsMake(0.0, self.bounds.size.width, 0.0, self.bounds.size.width);
    }
}

@end
