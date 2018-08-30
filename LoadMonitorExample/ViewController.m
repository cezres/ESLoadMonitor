//
//  ViewController.m
//  LoadMonitorExample
//
//  Created by 晨风 on 2018/8/27.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)load {
    NSLog(@"%s", __FUNCTION__);
    [NSThread sleepForTimeInterval:0.03];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
