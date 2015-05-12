//
//  UIImageView+WSZNetworking.m
//  UThing
//
//  Created by Apple on 15/5/5.
//  Copyright (c) 2015年 UThing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "UIImageView+WSZNetworking.h"


#pragma mark -

static char SZkAFImageRequestOperationObjectKey;

@interface UIImageView (sz_AFNetworking)
@property (readwrite, nonatomic, strong, setter = sz_setImageRequestOperation:) AFImageRequestOperation *sz_imageRequestOperation;
@end

@implementation UIImageView (sz_AFNetworking)
@dynamic sz_imageRequestOperation;
@end

#pragma mark -


@implementation UIImageView (WSZNetworking)
- (AFHTTPRequestOperation *)sz_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &SZkAFImageRequestOperationObjectKey);
}

- (void)sz_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &SZkAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)sz_sharedImageRequestOperationQueue {
    static NSOperationQueue *_sz_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sz_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_sz_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _sz_imageRequestOperationQueue;
}

#pragma mark -

- (void)sz_setImageWithURL:(NSURL *)url {
    [self sz_setImageWithURL:url placeholderImage:nil];
}

- (void)sz_setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self sz_setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)sz_setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    if (placeholderImage) {
        self.image = placeholderImage;
    }
    
    AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
    
#ifdef _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
    requestOperation.allowsInvalidSSLCertificate = YES;
#endif
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([urlRequest isEqual:[self.sz_imageRequestOperation request]]) {

            if (success) {
                success(operation.request, operation.response, responseObject);
            } else if (responseObject) {
                self.image = responseObject;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([urlRequest isEqual:[self.sz_imageRequestOperation request]]) {
            if (self.sz_imageRequestOperation == operation) {
                self.sz_imageRequestOperation = nil;
            }
            
            if (failure) {
                failure(operation.request, operation.response, error);
            }
        }
    }];
    
    self.sz_imageRequestOperation = requestOperation;
    
    [[[self class] sz_sharedImageRequestOperationQueue] addOperation:self.sz_imageRequestOperation];
    
}

- (void)sz_cancelImageRequestOperation {
    [self.sz_imageRequestOperation cancel];
    self.sz_imageRequestOperation = nil;
}



- (void)swz_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage {
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.operation", NULL);
    dispatch_async(queue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        UIImage *imge = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = imge;
        });
        
    });
}

@end

#pragma mark -

