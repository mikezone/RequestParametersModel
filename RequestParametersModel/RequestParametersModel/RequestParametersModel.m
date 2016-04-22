//
//  RequestModel.m
//  RequestModel
//
//  Created by Mike on 16/4/15.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "RequestParametersModel.h"
#import "NSDictionary+ConvertToQueryString.h"
#import "NSString+ConvertToDictionary.h"
#import <objc/runtime.h>

#define setValueForKeyWithType(type) \
do { \
    type value; \
    [anInvocation getArgument:&value atIndex:2]; \
    [self setValue:@(value) forPropertyName:pName]; \
} while (0);

#define restoreRealValueWithType(type, method) \
do { \
    type realValue = [(NSNumber *)value method]; \
    [anInvocation setReturnValue:&realValue]; \
} while (0);

#define AssertKeysCountEqualToValuesCount NSAssert(_allKeys.count == _allValues.count, @"");

typedef NS_ENUM(NSUInteger, MKObjCType) {
    MKObjCTypeNo = 0,
    MKObjCTypeVoid = 'v',
    MKObjCTypeChar = 'c',
    MKObjCTypeShort = 's',
    MKObjCTypeInt = 'i',
    MKObjCTypeLong = 'l',
    MKObjCTypeLonglong = 'q',
    
    MKObjCTypeFloat = 'f',
    MKObjCTypeDouble = 'd',
    
    MKObjCTypeUnsignedChar = 'C',
    MKObjCTypeUnsignedShort = 'S',
    MKObjCTypeUnsignedInt = 'I',
    MKObjCTypeUnsignedLong = 'L',
    MKObjCTypeUnsignedLonglong = 'Q',
    
    MKObjCTypeBool = 'B',
    
    MKObjCTypePointer = '^',
    MKObjCTypeCString = '*',
    MKObjCTypeObject = '@',
    MKObjCTypeClass = '#',
    MKObjCTypeSelector = ':',
    
    MKObjCTypeCArray = '[',
    MKObjCTypeCStruct = '{',
    MKObjCTypeCUnion = '(',
    
    MKObjCTypeBitfield = 'b',
    MKObjCTypeUnknown = '?'
};



static BOOL isInPropertyList(Class inClass, NSString *selName) {
    unsigned int count = 0;
    objc_property_t *propertyArray = class_copyPropertyList(inClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyArray[i];
        const char *pname = property_getName(property);
        NSString *pnameString = [NSString stringWithCString:pname encoding:NSUTF8StringEncoding];
        if ([pnameString isEqualToString:selName]) {
            return YES;
        }
    }
    return NO;
}

static BOOL isSetterTypeSelector(Class inClass, NSString *selName, NSString **pName) {
    if (![selName hasPrefix:@"set"]) {
        return NO;
    }
    NSString *removedSETString = [selName substringWithRange:NSMakeRange(3, [selName length]- 3)];
    if (!removedSETString.length) {
        return NO;
    }
    if (!([removedSETString characterAtIndex:removedSETString.length - 1] == ':')) {
        return NO;
    }
    NSString *removedColonString = [removedSETString substringToIndex:removedSETString.length -1];
    NSString *assumePropertyName = [removedColonString stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[removedColonString substringToIndex:1] lowercaseString]];
    if (pName != NULL) {
        *pName = assumePropertyName;
    }
    return isInPropertyList(inClass, assumePropertyName);
    
}

static BOOL isGetterTypeSelector(Class inClass, NSString *selName) {
    return isInPropertyList(inClass, selName);
}

static char typeEncodingForProperty(Class inClass, NSString *pName) {
    objc_property_t property = class_getProperty(inClass, [pName cStringUsingEncoding:NSUTF8StringEncoding]);
    const char *attriValue = property_copyAttributeValue(property, "T");
    if (strlen(attriValue) > 0) {
        return attriValue[0];
    }
    return MKObjCTypeNo;
}

@interface RequestParametersModel ()

@property (nonatomic, strong) NSMutableArray *allKeys;
@property (nonatomic, strong) NSMutableArray *allValues;

@end

@implementation RequestParametersModel

- (instancetype)init {
    if (self = [super init]) {
        _allKeys = [NSMutableArray array];
        _allValues = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithQueryString:(NSString *)queryString {
    if (self = [super init]) {
        NSDictionary *parameter = [queryString rpm_convertToDictionary];
        [self setInitialDataWithParameter:parameter];
    }
    return self;
}

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if (self = [super init]) {
        [self setInitialDataWithParameter:parameters];
    }
    return self;
}

- (void)setInitialDataWithParameter:(NSDictionary *)parameter {
    NSArray *sortedKeys = [parameter.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    _allKeys = sortedKeys.mutableCopy;
    _allValues = [NSMutableArray arrayWithCapacity:_allKeys.count];
    for (NSString *key in _allKeys) {
        id value = parameter[key];
        [_allValues addObject:value];
    }
}

- (NSString *)queryString {
    return [[self parameters] rpm_convertToQueryString];
}

- (NSDictionary *)parameters {
    AssertKeysCountEqualToValuesCount
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:_allKeys.count];
    for (NSUInteger i = 0; i < _allKeys.count; i++) {
        NSString *key = _allKeys[i];
        id value = _allValues[i];
        [parameters setObject:value forKey:key];
    }
    return parameters.copy;
}

#pragma mark - dynamic Handler

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {    
    NSString *selName = NSStringFromSelector(aSelector);
    NSString *pName;
    char typeEncoding;
    if (isSetterTypeSelector([self class], selName, &pName)) {
        typeEncoding = typeEncodingForProperty([self class], pName);
        NSString *OCString = [NSString stringWithFormat:@"v@:%c", typeEncoding];
        return [NSMethodSignature signatureWithObjCTypes:[OCString cStringUsingEncoding:NSUTF8StringEncoding]];
    } else if (isGetterTypeSelector([self class], selName)) {
        typeEncoding = typeEncodingForProperty([self class], selName);
        NSString *OCString = [NSString stringWithFormat:@"%c@:", typeEncoding];
        return [NSMethodSignature signatureWithObjCTypes:[OCString cStringUsingEncoding:NSUTF8StringEncoding]];
    } else {
        return [super methodSignatureForSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSString *selName = NSStringFromSelector([anInvocation selector]);
    NSString *pName = nil;
    if (isSetterTypeSelector([self class], selName, &pName)) { // setter
        [self setterHandlerWithClass:[self class] pName:pName invocation:anInvocation];
    } else if (isGetterTypeSelector([self class], selName)){ // getter
        [self getterHandlerWithClass:[self class] pName:pName invocation:anInvocation];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - settter Handler

- (void)setterHandlerWithClass:(Class)aClasss pName:(NSString *)pName invocation:(NSInvocation *)anInvocation {
    char typeEncoding = typeEncodingForProperty(aClasss, pName);
    if (typeEncoding == MKObjCTypeObject) {
        void *value;
        [anInvocation getArgument:&value atIndex:2];
        [self setValue:(__bridge id _Nonnull)(value) forPropertyName:pName];
        return;
    }
    switch (typeEncoding) {
        case MKObjCTypeChar:
            setValueForKeyWithType(char)
            break;
        case MKObjCTypeShort:
            setValueForKeyWithType(short)
            break;
        case MKObjCTypeInt:
            setValueForKeyWithType(int)
            break;
        case MKObjCTypeLong:
            setValueForKeyWithType(long)
            break;
        case MKObjCTypeLonglong:
            setValueForKeyWithType(long long)
            break;
        case MKObjCTypeUnsignedChar:
            setValueForKeyWithType(unsigned char)
            break;
        case MKObjCTypeUnsignedShort:
            setValueForKeyWithType(unsigned short)
            break;
        case MKObjCTypeUnsignedInt:
            setValueForKeyWithType(unsigned int)
            break;
        case MKObjCTypeUnsignedLong:
            setValueForKeyWithType(unsigned long)
            break;
        case MKObjCTypeUnsignedLonglong:
            setValueForKeyWithType(unsigned long long)
            break;
        case MKObjCTypeFloat:
            setValueForKeyWithType(float)
            break;
        case MKObjCTypeDouble:
            setValueForKeyWithType(double)
            break;
        case MKObjCTypeBool:
            setValueForKeyWithType(BOOL)
            break;
        default:
            break;
    }
}

- (void)setValue:(id)value forPropertyName:(NSString *)pName {
    if ([_allKeys containsObject:pName]) {
        NSUInteger index = [_allKeys indexOfObject:pName];
        [_allValues setObject:value atIndexedSubscript:index];
    } else {
        [_allKeys addObject:pName];
        [_allValues addObject:value];
    }
}

#pragma mark - getter Handler

- (void)getterHandlerWithClass:(Class)aClasss pName:(NSString *)pName invocation:(NSInvocation *)anInvocation {
    if ([_allKeys containsObject:pName]) {
        NSUInteger index = [_allKeys indexOfObject:pName];
        id value = [_allValues objectAtIndex:index];
        char typeEncoding = typeEncodingForProperty(aClasss, pName);
        if (typeEncoding == MKObjCTypeClass) {
            [anInvocation setReturnValue:&value];
            return;
        }
        
        switch (typeEncoding) {
            case MKObjCTypeChar:
                restoreRealValueWithType(char, charValue)
                break;
            case MKObjCTypeShort:
                restoreRealValueWithType(short, shortValue)
                break;
            case MKObjCTypeInt:
                restoreRealValueWithType(int, intValue)
                break;
            case MKObjCTypeLong:
                restoreRealValueWithType(long, longValue)
                break;
            case MKObjCTypeLonglong:
                restoreRealValueWithType(long long, longLongValue)
                break;
            case MKObjCTypeUnsignedChar:
                restoreRealValueWithType(unsigned char, unsignedCharValue)
                break;
            case MKObjCTypeUnsignedShort:
                restoreRealValueWithType(unsigned short, unsignedShortValue)
                break;
            case MKObjCTypeUnsignedInt:
                restoreRealValueWithType(unsigned int, unsignedIntValue)
                break;
            case MKObjCTypeUnsignedLong:
                restoreRealValueWithType(unsigned long, unsignedLongValue)
                break;
            case MKObjCTypeUnsignedLonglong:
                restoreRealValueWithType(unsigned long long, unsignedLongLongValue)
                break;
            case MKObjCTypeFloat:
                restoreRealValueWithType(float, floatValue)
                break;
            case MKObjCTypeDouble:
                restoreRealValueWithType(double, doubleValue)
                break;
            case MKObjCTypeBool:
                restoreRealValueWithType(BOOL, boolValue)
                break;
            default:
                break;
        }
    }
}

@end