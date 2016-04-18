//
//  RequestModel.h
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestParametersModel : NSObject

- (instancetype)initWithQueryString:(NSString *)queryString;
- (instancetype)initWithParameters:(NSDictionary *)parameters;

- (NSString *)queryString;
- (NSDictionary *)parameters;

@end
