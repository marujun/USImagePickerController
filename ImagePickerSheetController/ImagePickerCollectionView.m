//
//  ImagePickerCollectionView.m
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImagePickerCollectionView.h"

@interface ImagePickerCollectionView ()

@end

@implementation ImagePickerCollectionView

- (void)initialize
{
    [self.panGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
}

- (id)init {
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:[[ImagePreviewFlowLayout alloc] init]]) {
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

- (BOOL)bouncing
{
    return self.contentOffset.x < -self.contentInset.left || self.contentOffset.x + self.frame.size.width > self.contentSize.width + self.contentInset.right;
}

- (ImagePreviewFlowLayout *)imagePreviewLayout
{
    if ([self.collectionViewLayout isKindOfClass:[ImagePreviewFlowLayout class]]) {
        return (ImagePreviewFlowLayout *)self.collectionViewLayout;
    }
    return nil;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        
        if (CGPointEqualToPoint(translation, CGPointZero) && self.bouncing) {
            NSIndexPath *possibleIndexPath = [self indexPathForItemAtPoint:[gestureRecognizer locationInView:self]];
            if (possibleIndexPath) {
                [self selectItemAtIndexPath:possibleIndexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                    [self.delegate collectionView:self didSelectItemAtIndexPath:possibleIndexPath];
                }
            }
        }
    }
}



@end
