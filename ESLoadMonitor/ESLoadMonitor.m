//
//  ESLoadMonitor.m
//  ESLoadMonitor
//
//  Created by 晨风 on 2018/8/27.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import "ESLoadMonitor.h"


const char *kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY = "kSWIZZLED_LOAD_ASSOCIATION_KEY";



@implementation ESLoadMonitor

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (void)loadMonitor {
    printf("* %s *\n", __FUNCTION__);
    NSMutableArray *methods = objc_getAssociatedObject([self class], kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY);
    SEL sel = NSSelectorFromString([methods firstObject]);
    [methods removeObjectAtIndex:0];
    if (methods.count == 0) {
        objc_setAssociatedObject([self class], kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject([self class], kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY, methods, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:sel];
#pragma clang diagnostic pop
}

/// 测试方法
+ (void)testLoad {
    NSLog(@"%s", __FUNCTION__);
}


/**
 需要第一个加载当前动态库，以确保当前load第一个调用
 */
+ (void)load {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    uint32_t imageCount = _dyld_image_count();
    NSMutableArray *imagePaths = [NSMutableArray array];
    for (int i=0; i<imageCount; i++) {
        NSString *path = [NSString stringWithUTF8String:_dyld_get_image_name(i)];
        /// 过滤掉系统的动态库
        if ([path containsString:mainBundlePath] || [path containsString:@"Build/Products/"]) {
            [imagePaths addObject:path];
        }
    }
    
    NSLog(@"\n%@", imagePaths);
    
    /// load 监控方法
    SEL swizzledSelector = @selector(loadMonitor);
    Method swizzledMethod = class_getClassMethod([self class], swizzledSelector);
    
    for (NSString *path in imagePaths) {
        /// 遍历模块下的类
        NSString *imageName = [path lastPathComponent];
        unsigned int classCount = 0;
        const char **classNames = objc_copyClassNamesForImage(path.UTF8String, &classCount);
        for (int i=0; i<classCount; i++) {
            printf("%s - %s\n", imageName.UTF8String, classNames[i]);
            Class cls = NSClassFromString([NSString stringWithUTF8String:classNames[i]]);
            if ([self class] == cls) {
                continue;
            }
            /// 测试是否存在load方法
            Method testMethod = class_getClassMethod([self class], @selector(testLoad));
            if (class_addMethod(object_getClass(cls), @selector(load), method_getImplementation(testMethod), method_getTypeEncoding(testMethod))) {
                /// 添加成功，表明之前不存在+load方法
                continue;
            }
            
            /// 遍历类方法
            unsigned int methodCount = 0;
            Method *methods = class_copyMethodList(object_getClass(cls), &methodCount);
            for (int i=0; i<methodCount; i++) {
                Method method = methods[i];
                const char *methodName = sel_getName(method_getName(method));
                printf("\t%s\n", methodName);
                
                if (strcmp(methodName, "load") == 0) {
                    /// 记录新增方法名，方便之后调用
                    NSString *selName = [NSString stringWithFormat:@"%s_%d", kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY, i];
                    SEL sel = NSSelectorFromString(selName);
                    NSMutableArray *array = objc_getAssociatedObject(cls, kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY);
                    if (!array) {
                        array = [NSMutableArray array];
                    }
                    [array addObject:selName];
                    objc_setAssociatedObject(cls, kSWIZZLED_LOAD_METHODS_ASSOCIATION_KEY, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    /// 为其添加一个新的方法，IMP为监控方法的IMP
                    class_addMethod(object_getClass(cls), sel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
                    /// 交换两个方法的IMP
                    method_exchangeImplementations(method, class_getClassMethod(object_getClass(cls), sel));
                }
                
            }
            
            
//            if (class_addMethod(object_getClass(cls), @selector(load), method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
//                /// 不存在 load 方法
//            }
//            else {
//                /// 存在 load 方法
////                printf("\tload_\n");
//            }
            
            
        }
        
        
    }
    
    
}

@end



