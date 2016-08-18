//
//  PreviewSupplementaryView.m
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "PreviewSupplementaryView.h"
#import "ImagePickerSheetController.h"

@implementation PreviewSupplementaryView

- (id)initWithFrame:(CGRect)frame {
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
    _buttonInset = UIEdgeInsetsZero;
    
    _button = [[UIButton alloc] init];
    _button.tintColor = [UIColor whiteColor];
    _button.userInteractionEnabled = false;
    [_button setImage:[[self class] checkmarkImage] forState:UIControlStateNormal];
    [_button setImage:[[self class] selectedCheckmarkImage] forState:UIControlStateSelected];
    
    [self addSubview:_button];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _selected = false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_button sizeToFit];
    
    CGRect frame = _button.frame;
    frame.origin.x = _buttonInset.left;
    frame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(frame)-_buttonInset.bottom;
    _button.frame = frame;
    _button.layer.cornerRadius = CGRectGetHeight(frame) / 2.0;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    _button.selected = _selected;
    [self reloadButtonBackgroundColor];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    [self reloadButtonBackgroundColor];
}

- (void)reloadButtonBackgroundColor
{
    _button.backgroundColor = _selected ? self.tintColor : nil;
}

+ (UIImage *)checkmarkImage
{
    NSBundle *bundle = [NSBundle bundleForClass:[ImagePickerSheetController class]];
    
    UIImage *image = nil;
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        image = [UIImage imageNamed:@"PreviewSupplementaryView-Checkmark" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        image = [UIImage imageNamed:@"PreviewSupplementaryView-Checkmark"];
    }
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)selectedCheckmarkImage
{
    NSBundle *bundle = [NSBundle bundleForClass:[ImagePickerSheetController class]];
    
    UIImage *image = nil;
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        image = [UIImage imageNamed:@"PreviewSupplementaryView-Checkmark-Selected" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        image = [UIImage imageNamed:@"PreviewSupplementaryView-Checkmark-Selected"];
    }
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
