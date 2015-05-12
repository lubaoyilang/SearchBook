//
//  UIImageView+WSZNetworking.h
//  UThing
//
//  Created by Apple on 15/5/5.
//  Copyright (c) 2015年 UThing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AFImageRequestOperation.h"

#import <Availability.h>

@interface UIImageView (WSZNetworking)

- (void)sz_setImageWithURL:(NSURL *)url;
- (void)sz_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage;
- (void)swz_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage;

@end
