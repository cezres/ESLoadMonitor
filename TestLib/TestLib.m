//
//  TestLib.m
//  TestLib
//
//  Created by 晨风 on 2018/8/29.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (xxxxx)

@end


@implementation NSObject (xxxxx)


+ (void)load {
    NSLog(@"%s", __FUNCTION__);
    [NSThread sleepForTimeInterval:0.3];
}

@end
