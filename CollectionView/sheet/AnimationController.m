//
//  AnimationController.m
//  CollectionView
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "AnimationController.h"

@interface AnimationController ()

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, strong) ImagePickerSheetController *imagePickerSheetController;

@end

@implementation AnimationController

#pragma mark - Initialization
- (instancetype)init:(ImagePickerSheetController *)imagePickerSheetController presenting:(BOOL)presenting
{
    if (self = [super init]) {
        self.imagePickerSheetController = imagePickerSheetController;
        self.presenting = presenting;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_presenting) {
        [self animatePresentation:transitionContext];
    }
    else{
        [self animateDismissal:transitionContext];
    }
}

#pragma mark - Animation
- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)context
{
    UIView *containerView = [context containerView];
    [containerView addSubview:_imagePickerSheetController.view];
    
    CGFloat tableViewOriginY = _imagePickerSheetController.tableView.frame.origin.y;
    
    __block CGRect frame = _imagePickerSheetController.tableView.frame;
    frame.origin.y = CGRectGetMaxY(containerView.bounds);
    _imagePickerSheetController.tableView.frame = frame;
    _imagePickerSheetController.backgroundView.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:context] animations:^{
        frame.origin.y = tableViewOriginY;
        _imagePickerSheetController.tableView.frame = frame;
        _imagePickerSheetController.backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [context completeTransition:true];
    }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)context
{
    UIView *containerView = [context containerView];
    
    [UIView animateWithDuration:[self transitionDuration:context] animations:^{
        CGRect frame = _imagePickerSheetController.tableView.frame;
        frame.origin.y = CGRectGetMaxY(containerView.bounds);
        _imagePickerSheetController.tableView.frame = frame;
        _imagePickerSheetController.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [_imagePickerSheetController.view removeFromSuperview];
        [context completeTransition:true];
    }];
}

@end
