//
//  NSDictionary+ConvertToQueryString.m
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NSDictionary+ConvertToQueryString.h"
#import "AFNetworking.h"

@implementation NSDictionary (ConvertToQueryString)

- (NSString *)convertToQueryString {
    if (!self || [self isEqual:[NSNull null]]) {
        return @"";
    }
//#if AFN Version < 3.0
//    return AFQueryStringFromParametersWithEncoding(self, NSUTF8StringEncoding);
//#else
    return AFQueryStringFromParameters(self);
//#endif
}

@end
