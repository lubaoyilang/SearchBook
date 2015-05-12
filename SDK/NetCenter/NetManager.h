//
//  NetManager.h
//  UThing
//
//  Created by luyuda on 15/1/30.
//  Copyright (c) 2015年 UThing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NetError  = 0, //网络出错
    sigError,//签名出错
    DataError //数据result 返回 error
    
    
} ErrorCode;






//基于delegate的 回调方法
@protocol NetBackProtocol <NSObject>

@optional
- (void)requestSuccess:(id)obj NetName:(NSString*)name;//成功不会自己hide HUB 需要自己来操作
- (void)requestFailure:(ErrorCode)code JSON:(id)obj NetName:(NSString*)name;//失败会自动hide 掉 HUB，但是这个时候需要你从缓存中调取数据

@end


@interface NetManager : NSObject

+(instancetype)manager;


/**
 *  block方式 回调网络请求   回调json 就是已经解析完成的数据
 *
 *  @param urlRequest 请求网络参数
 *  @param success    成功block   成功不会自己hide HUB 需要自己来操作
 *  @param failure    失败block   失败会自动hide 掉 HUB，但是这个时候需要你从缓存中调取数据
 */

- (void)postRequest:(NSURLRequest *)urlRequest isShowMub:(BOOL)isshow success:(void (^)(NSURLRequest *request, id JSON))success
            failure:(void (^)(ErrorCode code,id json))failure;




/**
 *  用delegate方式来回调
 *
 *  @param Request  请求网络参数
 *  @param delegate 代理
 *  @param name     本次网络请求名称
 */


- (void)postRequest:(NSURLRequest*)Request delegate:(id)delegate NetName:(NSString*)name isShowMub:(BOOL)isshow;


@end
