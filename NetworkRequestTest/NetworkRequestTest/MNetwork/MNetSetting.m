//
//  MNetSetting.m
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/20.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import "MNetSetting.h"
#import "MNetRequestModel.h"
#import "MNetworkUtils.h"
#import <MBProgressHUD.h>
#import "MBProgressHUD+MJ.h"
#import <AFNetworking.h>

@implementation MNetSetting

-(void)requestDataFromHostURL:(NSString *)url andParameter:(NSDictionary *)parameter success:(void (^)(id))success failure:(void (^)(NSError *))failure netSeting:(MNetSetting *)seting{
    
    self.hostUrl = url;
    self.paramet = parameter;
    seting.hostUrl = url;
    seting.paramet = parameter;
    self.cashTime = seting.cashTime;
    __block MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    
    HUD.animationType = MBProgressHUDAnimationFade;
    HUD.label.text = @"正在加载";
    [HUD showAnimated:YES];
    HUD.hidden = seting.isHidenHUD;
    
    if (seting.cashSeting == MCacheNoSave) {
        //默认,不缓存,比如登录
        [MNetRequestModel netRequestSeting:seting success:^(id responseData) {
            if (responseData != nil) {
                //有字段校验
                if (seting.jsonValidator) {
                   BOOL result = [MNetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                    if (result) {
                        //字段验证正确
                        success(responseData);
                    }else{
                        //字段验证不正确
                    }
                }else{
                    success(responseData);
                }
                [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
            }
        } failure:^(NSError *error) {
            failure(error);
            HUD.animationType = MBProgressHUDModeText;
            HUD.label.text = @"请求失败,重新发送请求";
            [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
        }];
    }else {
        //设置了缓存,如果没有设置缓存时间,默认3分钟缓存时间
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //检测文件路径存不存在
        BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
        __weak typeof(self) weakSelf = self;
        //如果存在,再检查文件有没有过期,日期间隔根据自己定的
        if ((isFileExist && !seting.isRefresh) || seting.isReadCash) {
            id data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (data != nil) {
                //如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1
                NSInteger time = [MNetworkUtils compareCurrentTime:[self getCurrentTime] withFileCreatTime:[self getFileCreateTime]];
                if (time == 1) {
                    //当前时间超过文件创建时间,刷新数据
                    [MNetRequestModel netRequestSeting:seting success:^(id responseData) {
                        if (responseData != nil) {
                            [weakSelf saveCashDataForArchiver:responseData requestSeting:seting];
                            //有字段校验
                            if (seting.jsonValidator) {
                                BOOL result = [MNetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                                if (result) {
                                    //字段验证成功
                                    success(responseData);
                                }else{
                                    //字段验证失败
                                }
                            }else{
                                success(responseData);
                            }
                            [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                        }
                        
                    } failure:^(NSError *error) {
                        failure(error);
                        HUD.animationType = MBProgressHUDModeText;
                        HUD.label.text=@"请求失败,重新发送请求";
                        [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                    }];
                }else{
                    //文件创建时间小于当前时间,返回缓存数据
                    success(data);
                    [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                    //节省流量,就取消这个
                    //[self getNewDataForCash:seting];
                }
            }
        }else{
            [MNetRequestModel netRequestSeting:seting success:^(id responseData) {
                if (responseData != nil) {
                    [weakSelf saveCashDataForArchiver:responseData requestSeting:seting];
                     //有字段校验
                    if (seting.jsonValidator) {
                        BOOL result = [MNetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                        if (result) {
                            //字段验证成功
                            success(responseData);
                        }else{
                            //字段验证失败
                        }
                    }else{
                        success(responseData);
                    }
                    [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                }
            } failure:^(NSError *error) {
                failure(error);
                HUD.animationType = MBProgressHUDModeText;
                HUD.label.text=@"请求失败,重新发送请求";
                [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
            }];
        }
    }
}

/**
 将数据存储到本地,验证是否符合json字段类型

 @param responseData 网络请求获取的数据
 @param seting 网络配置
 */
-(void)saveCashDataForArchiver:(id)responseData requestSeting:(MNetSetting *)seting{
    NSString *path = [self cacheFilePath];
    if (responseData != nil) {
        @try {
            if (seting.jsonValidator) {
                //如果有格式验证就进行验证
                BOOL result = [MNetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                if (result) {
                    //字段验证成功,进行缓存
                   [NSKeyedArchiver archiveRootObject:responseData toFile:path]; 
                }else{
                    //格式不正确
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    //检测文件路径存不存在
                    BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
                    if (isFileExist) {
                        //如果文件存在,肯定是老数据,把文件删掉
                        NSError *error = nil;
                        [fileManager removeItemAtPath:path error:&error];
                    }
                }
            }else{
                //没有验证直接存储
               [NSKeyedArchiver archiveRootObject:responseData toFile:path];
            }
        } @catch (NSException *exception) {
            NSLog(@"Save cache failed, reason = %@", exception.reason);
        }
    }
}

//获取新的数据
-(void)getNewDataForCash:(MNetSetting *)seting{
    [MNetRequestModel netRequestSeting:seting success:^(id responseData) {
        if (responseData != nil) {
            @try {
                [self saveCashDataForArchiver:responseData requestSeting:seting];
                
            } @catch (NSException *exception) {
                NSLog(@"Save cache failed, reason = %@", exception.reason);
            }
        }
    } failure:^(NSError *error) {
    }];
}
//获取当前时间
- (NSDate *)getCurrentTime{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *dateTime=[formatter stringFromDate:[NSDate date]];
    NSDate *date = [formatter dateFromString:dateTime];
    NSTimeInterval time = (self.cashTime == 0 ? 3 * 60 : self.cashTime * 60);
    NSDate *currentTime = [date dateByAddingTimeInterval:-time];
    return currentTime;
}
//获取文件夹创建时间
- (NSDate *)getFileCreateTime{
    NSString *path = [self cacheFilePath];
    NSError * error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //通过文件管理器来获得属性
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
    return fileCreateDate;
}


//根据url和参数创建路径
- (NSString *)cacheFilePath{
    
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

//将请求路径和参数拼接成文件名称
- (NSString *)cacheFileName{
    
    NSString *requestInfo = [NSString stringWithFormat:@"%@%@",self.hostUrl,self.paramet];
//    NSLog(@"%@",[MNetworkUtils md5StringFromString:requestInfo]);
    return [MNetworkUtils md5StringFromString:requestInfo];

}
//创建根路径 -文件夹
- (NSString *)cacheBasePath {
    //放入cash文件夹下,为了让手机自动清理缓存文件,避免产生垃圾
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"MLazyRequestCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
    return path;
}
//创建文件夹
-(void)createBaseDirectoryAtPath:(NSString *)path{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}


// 是否wifi
+ (BOOL)isEnableWIFI{
    
    BOOL iswifi = NO;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi){
        
        iswifi = YES;
    }
    return iswifi;
}

// 是否3G
+ (BOOL)isEnableWWAN{
    
    BOOL noNet = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;
    
    BOOL wifi = [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
    
    if (noNet && wifi)//有网且不是wifi
        return YES;
    else
        return NO;
    
    
}
//网络是否可用
+ (BOOL)isNoNet{
    
    BOOL noNet = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable;
    if (noNet) {
        return YES;
    }
    else
        return NO;
}


@end
