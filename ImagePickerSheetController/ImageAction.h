//
//  ImageAction.h
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ImageActionStyleDefault ,
    ImageActionStyleCancel
} ImageActionStyle;

@interface ImageAction : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) ImageActionStyle style;

@property (nonatomic, copy) NSString * (^secondaryTitle)(NSInteger);

@property (nonatomic, copy) void (^handler)(ImageAction *);

@property (nonatomic, copy) void (^secondaryHandler)(ImageAction *, NSInteger);

- (void)handle:(NSInteger)numberOfImages;

@end
