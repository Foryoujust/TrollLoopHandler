//
//  TrollLoopHanlder.h
//  OSSDemo
//
//  Created by Troll on 16/1/15.
//  Copyright © 2016年 Troll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TrollLoopDirection) {
    TrollLoopDirectionLeft = 0,
    TrollLoopDirectionRight = 1
};

@interface TrollLoopHanlder : NSObject

- (instancetype)initWithFrame:(CGRect)frame inView:(UIView *)view;

- (void)setLoopDirection:(TrollLoopDirection)direction;
- (void)setContentImages:(NSArray *)images;
- (void)beginLoopWithInterval:(NSTimeInterval)timeInterval;
- (void)endLoop;


@end
