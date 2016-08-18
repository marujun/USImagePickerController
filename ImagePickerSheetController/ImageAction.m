//
//  ImageAction.m
//  ImagePickerSheetController
//
//  Created by marujun on 15/8/6.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import "ImageAction.h"

@implementation ImageAction

- (void)handle:(NSInteger)numberOfImages
{
    if (numberOfImages > 0) {
        _secondaryHandler?_secondaryHandler(self, numberOfImages):nil;
    }
    else{
        _handler?_handler(self):nil;
    }
}

@end
