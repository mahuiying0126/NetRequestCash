//
//  MNetworkUtils.m
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/21.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import "MNetworkUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <MBProgressHUD.h>
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>

@implementation MNetworkUtils
//md5加密
+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

//如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime withFileCreatTime:(NSDate *)fileCreatTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *oneDayStr = [dateFormatter stringFromDate:currentTime];
    NSString *anotherDayStr = [dateFormatter stringFromDate:fileCreatTime];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"currentTime : %@, fileCreatTime : %@", currentTime, fileCreatTime);
    NSInteger aa = 0;
    if (result == NSOrderedDescending) {
        //文件创建时间超过当前时间,刷新数据
        aa = 1;
    }
    else if (result == NSOrderedAscending){
        //文件创建时间小于当前时间,返回缓存数据
        aa = -1;
    }
    //NSLog(@"Both dates are the same");
    return aa;
    
}

//json字段检验
+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}



@end
