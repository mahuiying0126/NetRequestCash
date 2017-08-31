//
//  MNetRequestModel.h
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/20.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNetSetting.h"
@interface MNetRequestModel : NSObject

/**
 网络请求

 @param seting 网络请求设置
 @param success 网络请求成功回调
 @param failure 网络请求失败回调
 */
+ (void)netRequestSeting:(MNetSetting *)seting
                 success:(void (^)(id responseData))success
                 failure:(void (^)(NSError *error))failure;
@end
