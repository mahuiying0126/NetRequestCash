//
//  MNetworkUtils.h
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/21.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNetworkUtils : NSObject

/**
 将路径进行md5加密

 @param string 数据文件储存路径
 @return 加密后的文件路径
 */
+ (NSString *)md5StringFromString:(NSString *)string;

/**
 如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1

 @param currentTime 当前时间
 @param fileCreatTime 文件创建时间
 @return -1 文件没有过期; 0 时间刚好相等; 1 文件已过期需要刷新数据
 */
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime
              withFileCreatTime:(NSDate *)fileCreatTime;

/**
 将原数据进行json字段类型检验

 @param json 请求下来的原数据
 @param jsonValidator 要检验的json字段类型
 @return YES 要检测的字段类型符合; NO 反之
 */
+ (BOOL)validateJSON:(id)json
       withValidator:(id)jsonValidator;
@end
