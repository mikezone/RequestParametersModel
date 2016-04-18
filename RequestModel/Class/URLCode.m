//
//  URLCode.m
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "URLCode.h"
#import "AFNetworking.h"

@implementation URLCode

+ (NSString *)encodeFromString:(NSString *)string {
    return AFPercentEscapedStringFromString(string);
}

+ (NSString *)decodeFromString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [string stringByRemovingPercentEncoding];
}

@end
