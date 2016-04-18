//
//  Search.h
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestParametersModel.h"

@interface Search : RequestParametersModel

@property (nonatomic, copy) NSString *wd;
@property (nonatomic, copy) NSString *tn;
@property (nonatomic, assign) NSUInteger index;

@end
