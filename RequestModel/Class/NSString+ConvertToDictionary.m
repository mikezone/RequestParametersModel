//
//  NSString+ConvertToDictionary.m
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NSString+ConvertToDictionary.h"
#import "URLCode.h"

@implementation NSString (ConvertToDictionary)

- (NSDictionary *)convertToDictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *parts = [self componentsSeparatedByString:@"&"];
    
    for (NSString *part in parts) {
        if ([part length] == 0) {
            continue;
        }
        
        NSRange index = [part rangeOfString:@"="];
        NSString *key;
        NSString *value;
        
        if (index.location == NSNotFound) {
            key = part;
            value = @"";
        } else {
            key = [part substringToIndex:index.location];
            value = [part substringFromIndex:index.location + index.length];
        }
        
        key = [URLCode decodeFromString:key];
        value = [URLCode decodeFromString:value];
        if (key && value) {
            result[key] = value;
        }
    }
    return result;
}

@end
