//
//  MySensor.m
//  SensorStudy
//
//  Created by Dio Brand on 2022/9/2.
//

#import "MySensor.h"
//#import <CoreMotion/CoreMotion.h>
#import <objc/runtime.h>

// 单例
static MySensor *staticInstance = nil;
@implementation MySensor
// 生成单例
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[super allocWithZone:NULL] init]; // 与下面两个方匹配
    });
    return staticInstance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [[self class] sharedManager];
}


-(void)shake_hook {
//    Method oriMethod = class_getInstanceMethod(objc_getClass("CMMotionManager"), @selector(startAccelerometerUpdatesToQueue:withHandler:));
//    Method curMethod = class_getInstanceMethod(objc_getClass("MySensor"), @selector(startAccelerometerUpdatesToQueue:withHandler:));
//    method_exchangeImplementations(oriMethod, curMethod);
    
    Method oriMethod = class_getInstanceMethod(objc_getClass("CMAccelerometerData"), @selector(acceleration));
    Method curMethod = class_getInstanceMethod(objc_getClass("MySensor"), @selector(acceleration));
    method_exchangeImplementations(oriMethod, curMethod);
}

//- (void)startAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMAccelerometerHandler)handler API_UNAVAILABLE(tvos) {
//
//}

typedef struct {
    double x;
    double y;
    double z;
} CMAcceleration;

-(CMAcceleration)acceleration {
    unsigned long bit_len = 10000000; // 为了取随机数,先扩大数据位数
    double range_num = 0.01;
    //获取时间戳
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSInteger time = interval;
//    NSLog(@"time:%ld",time);
    NSInteger last_3bit = time % 100;
    if((last_3bit % 20) == 0) {
        range_num = 3;
    }
    unsigned long top_len = range_num * bit_len;
    
    // x轴 随机量
    int x_random = arc4random() % top_len;
    double x = ((double) x_random) / bit_len;
    if ((arc4random() % 2)) {
        x = -x;
    }
    
    // y轴 随机量
    int y_random = arc4random() % top_len;
    double y = ((double) y_random) / bit_len;
    if ((arc4random() % 2)) {
        y = -y;
    }
    
    // z轴 随机量
    int z_random = arc4random() % top_len;
    double z = ((double) z_random) / bit_len;
    if ((arc4random() % 2)) {
        z = -z;
    }
    
    CMAcceleration *acc = (CMAcceleration *)malloc(sizeof(CMAcceleration));
    acc->x = x;
    acc->y = y;
    acc->z = z;
    return *acc;
}

@end
