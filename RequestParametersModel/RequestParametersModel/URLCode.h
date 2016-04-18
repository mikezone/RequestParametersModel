//
//  URLCode.h
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCode : NSObject

+ (NSString *)encodeFromString:(NSString *)string;
+ (NSString *)decodeFromString:(NSString *)string;

@end
