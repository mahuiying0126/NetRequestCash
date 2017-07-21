//
//  MNetRequestModel.m
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/20.
//  Copyright © 2017年 edu268. All rights reserved.
//

#import "MNetRequestModel.h"

@implementation MNetRequestModel

+ (void)netRequestSeting:(MNetSetting *)seting success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure{
    if ([MNetSetting isNoNet]) {
        [MBProgressHUD showMBPAlertView:@"当前网络不可用" withSecond:1.5];
        return;
    }
   
    [self printRequestUrlString:seting.hostUrl withParamter:seting.paramet];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:10.f];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    if (seting.isHttpsRequest) {
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"nideke" ofType:@"cer"];
        NSData * certData =[NSData dataWithContentsOfFile:cerPath];
        NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:NO];
        //设置证书
        [securityPolicy setValidatesDomainName:YES];
        [securityPolicy setPinnedCertificates:certSet];
        manager.securityPolicy = securityPolicy;
    }
    
    if (seting.requestStytle == MRequestMethodPOST) {
        [manager POST:seting.hostUrl parameters:seting.paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
            
            if (success != nil){
                success(responseObject);
            }
            
            
        }failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error){
            
            if (failure != nil)
            {
                failure(error);
            }
        }];
        
    }else{
        [manager GET:seting.hostUrl parameters:seting.paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
            
            if (success != nil){
                success(responseObject);
            }
            
            
        }failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error){
            
            if (failure != nil)
            {
                failure(error);
            }
        }];
    }
    
}


+ (void)printRequestUrlString:(NSString *)urlString withParamter:(NSDictionary *)dic
{
    NSArray *dicKeysArray = [dic allKeys];
    NSString *urlWithParamterString = urlString;
    if (dicKeysArray.count != 0){
        urlWithParamterString = [urlWithParamterString stringByAppendingString:@"?"];
    }
    for (NSInteger i = 0; i < dicKeysArray.count; i++){
        
        urlWithParamterString = [urlWithParamterString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", dicKeysArray[i], [dic objectForKey:dicKeysArray[i]]]];
        if (i == dicKeysArray.count - 1){
            urlWithParamterString = [urlWithParamterString substringToIndex:urlWithParamterString.length - 1];
        }
    }
    
    NSLog(@"\n\n路径--%@", urlWithParamterString);
}

@end
