//
//  ESLoadMonitor.h
//  ESLoadMonitor
//
//  Created by 晨风 on 2018/8/27.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for ESLoadMonitor.
FOUNDATION_EXPORT double ESLoadMonitorVersionNumber;

//! Project version string for ESLoadMonitor.
FOUNDATION_EXPORT const unsigned char ESLoadMonitorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ESLoadMonitor/PublicHeader.h>

@class ESLoadMonitor;

@protocol ESLoadMonitorDelegate <NSObject>


@end


/**
 监控load方法的调用
 */
@interface ESLoadMonitor : NSObject



@end


