//
//  DBObject.h
//  MCFriends
//
//  Created by marujun on 15/7/18.
//  Copyright (c) 2015年 marujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBObject : NSObject

- (NSArray *)properties;

- (NSDictionary *)dictionary;

- (instancetype)initWithObject:(id)object;

- (void)populateValue:(id)value forKey:(NSString *)key;

- (void)populateWithObject:(id)object;

@end
