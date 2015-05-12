//
//  NetManager.m
//  UThing
//
//  Created by luyuda on 15/1/30.
//  Copyright (c) 2015年 UThing. All rights reserved.
//

#import "NetManager.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

static NetManager *manager = nil;
@implementation NetManager

+(instancetype)manager
{
    if (manager == nil) {
        manager = [[NetManager alloc] init];
    }
    return manager;
}



- (id)init
{
    if(self = [super init]){
    
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    }
    
    return self;
        
        
}




- (void)postRequest:(NSURLRequest *)urlRequest isShowMub:(BOOL)isshow success:(void (^)(NSURLRequest *request, id JSON))success
            failure:(void (^)(ErrorCode code,id json))failure
{
    AFJSONRequestOperation *post = [AFJSONRequestOperation  JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(request,JSON);
                [self hideHub];
            });
            
            
       

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        dispatch_async(dispatch_get_main_queue(), ^{
        
            failure(NetError,JSON);
             [self hideHub];
        });
        
        
    }];
    if (isshow) {
        [self showHub:@"加载中"];
    }
    
    [post start];
    
    
}


- (void)postRequest:(NSURLRequest*)Request delegate:(id)delegate NetName:(NSString*)name isShowMub:(BOOL)isshow
{
    
    AFJSONRequestOperation *post = [AFJSONRequestOperation  JSONRequestOperationWithRequest:Request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        


            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (delegate &&[delegate respondsToSelector:@selector(requestSuccess:NetName:)]) {
                    [delegate requestSuccess:JSON NetName:name];
                    
                }
                [self hideHub];
                
                
            });

        
            
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(requestFailure:JSON:NetName:)]) {
                [delegate requestFailure:NetError JSON:JSON NetName:name];
            }
             [self hideHub];
        
        });
        
    }];
    
    if (isshow) {
        [self showHub:@"加载中"];
    }
    [post start];
    
    

    

}



- (void)showHub:(NSString*)text
{
    
    [SVProgressHUD showWithStatus:@"加载中,请稍等..." maskType:SVProgressHUDMaskTypeGradient];
    
}
- (void)hideHub
{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    
}






@end
