//
//  MNetSetting.h
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/20.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 缓存设置

 - MCacheNoSave: 不缓存数据
 - MCacheSave: 缓存数据
 */
typedef NS_ENUM(NSUInteger, MCashTime) {
    MCacheNoSave = 0,
    MCacheSave,
};

/**
 网络请求方式

 - MRequestMethodPOST: POST请求
 - NRequestMethodGET: GET请求
 */
typedef NS_ENUM(NSUInteger, MRequesttMethod) {
    MRequestMethodPOST = 0,
    NRequestMethodGET = 1,
};


@interface MNetSetting : NSObject

/** *是否显示HUD,默认显示*/
@property (nonatomic, assign) BOOL isHidenHUD;
/** *是否是HTTPS请求,默认是NO*/
@property (nonatomic, assign) BOOL isHttpsRequest;
/** *缓存设置策略*/
@property (nonatomic, assign) MCashTime cashSeting;
/** *是否刷新数据*/
@property (nonatomic, assign) BOOL isRefresh;
/** *是否读取缓存*/
@property (nonatomic, assign) BOOL isReadCash;
/** *缓存时间*/
@property (nonatomic, assign) NSInteger cashTime;
/** *请求方式,默认POST请求*/
@property (nonatomic, assign) MRequesttMethod requestStytle;
/** *地址*/
@property (nonatomic, strong) NSString *hostUrl;
/** *参数*/
@property (nonatomic, strong) NSDictionary *paramet;
/** *验证json格式*/
@property (nonatomic, strong) id jsonValidator;

/**
 通过url获取数据或获取缓存数据

 @param url 请求地址
 @param parameter 参数
 @param success 成功回调
 @param failure 失败回调
 @param seting 网络请求设置
 */
-(void)requestDataFromHostURL:(NSString *)url
                 andParameter:(NSDictionary *)parameter
                      success:(void (^)(id responseData))success
                      failure:(void (^)(NSError *error))failure
                    netSeting:(MNetSetting *)seting;

/**
 wifi网络是否可用

 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWIFI;

/**
 蜂窝数据是否可用

 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWWAN;

/**
 当前网络状态是否可用

 @return YES,网络状态不可用 NO,网络状态可用
 */
+ (BOOL) isNoNet;

@end
