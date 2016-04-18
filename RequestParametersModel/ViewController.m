//
//  ViewController.m
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "ViewController.h"
#import "Search.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // https://www.baidu.com/s?wd=aa&tn=baiduhome_pg
    
    Search *search = [[Search alloc] init];
//    search.wd(@"x").tn(@"y"); // 暂未实现这种调用方法
    search.wd = @"aa";
    search.tn = @"baiduhome_pg";
    NSLog(@"%@", search.parameters);
    NSLog(@"%@", search.queryString);
    
    NSLog(@"--------------------------------");
    Search *search2 = [[Search alloc] initWithQueryString:@"tn=baiduhome_pg&wd=aa"];
    NSLog(@"%@", search2.parameters);
    NSLog(@"%@", search2.queryString);
    
    NSLog(@"--------------------------------");
    Search *search3 = [[Search alloc] initWithParameters:@{@"tn": @"baiduhome_pg",
        @"wd":@"aa"}];
    NSLog(@"%@", search3.parameters);
    NSLog(@"%@", search3.queryString);
    search3.index = 5;
    NSLog(@"%@", search3.parameters);
    NSLog(@"%@", search3.queryString);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    Search *search = [[Search alloc] init];
    search.wd = @"aa";
    search.tn = @"baiduhome_pg";
    search.index = 10;
    
    // request
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://www.baidu.com" parameters:search.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

@end
