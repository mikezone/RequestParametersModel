# RequestParametersModel
Expediently build parameters when send HTTP request.

# Usage

1.Create a Model extends `RequestParametersModel`, use `dynamic` mark its property;
```objectivec
@interface Search : RequestParametersModel

@property (nonatomic, copy) NSString *wd;
@property (nonatomic, copy) NSString *tn;
@property (nonatomic, assign) NSUInteger index;

@end

@implementation Search

@dynamic wd;
@dynamic tn;
@dynamic index;

@end
```

2.Build parameter using kvc-Style
```objectivec
Search *search = [[Search alloc] init];
search.wd = @"aa";
search.tn = @"baiduhome_pg";
search.index = 10;
```

3.Request HTTP interface
```objectivec
AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
manager.responseSerializer = [AFHTTPResponseSerializer serializer];
[manager GET:@"https://www.baidu.com" parameters:search.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", [error localizedDescription]);
}];
```

# Additional functions

Use queryString initialize a model
```objectivec
Search *search2 = [[Search alloc] initWithQueryString:@"tn=baiduhome_pg&wd=aa"];
NSLog(@"%@", search2.parameters); // { tn = "baiduhome_pg"; wd = aa; }
NSLog(@"%@", search2.queryString); // tn=baiduhome_pg&wd=aa
```

Use parameters dictionary initialize a model
```objectivec
Search *search3 = [[Search alloc] initWithParameters:@{@"tn": @"baiduhome_pg", @"wd":@"aa"}];
NSLog(@"%@", search3.parameters); // { tn = "baiduhome_pg"; wd = aa; }
search3.index = 5;
NSLog(@"%@", search3.queryString); // index=5&tn=baiduhome_pg&wd=aa
```

# Components
`NSDictionary+ConvertToQueryString`: convert a parameters(NSDictionary type) to a queryString,

`NSString+ConvertToDictionary`: convert a queryString(NSString type) to a dictionary,

`URLCode`: a tool be use for `URLEncode` and `URLDecode`.

