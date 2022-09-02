//
//  ViewController.m
//  SensorStudy
//
//  Created by Dio Brand on 2022/9/2.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "MySensor.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *shakeBtn;
@property (strong,nonatomic) CMMotionManager *motionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 1;//加速仪更新频率，以秒为单位
    
    [[MySensor sharedManager] shake_hook];
}

- (IBAction)startAction:(UIButton *)sender {
    [self startAccelerometer];
    [self.shakeBtn setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [self startAccelerometer];
    //viewDidAppear中加入
    // 应用进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 应用进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

//对应上面的通知中心回调的消息接收
-(void)receiveNotification:(NSNotification *)notification {
    // 应用进入后台 停止搜集传感器数据
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self.motionManager stopAccelerometerUpdates];
    }else{
        // 应用进入前台 开始搜集传感器数据
        [self startAccelerometer];
    }
}

-(void)startAccelerometer {
    //以push的方式更新并在block中接收加速度
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelertionData:accelerometerData.acceleration];
        if (error) {
            NSLog(@"motion error:%@",error);
        }
    }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration {
    NSLog(@"x:%f,y:%f,z:%f",acceleration.x,acceleration.y,acceleration.z);
    //综合3个方向的加速度
    double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 )
                               + pow( acceleration.z , 2) );
    //当综合加速度大于1.5时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
    if (accelerameter > 1.5f) {
        //立即停止更新加速仪（很重要！）
        [self.motionManager stopAccelerometerUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //UI线程必须在此block内执行，例如摇一摇动画、UIAlertView之类
            NSLog(@"摇一摇触发");
            [self.shakeBtn setHidden:NO];
        });
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    //停止加速仪更新（很重要！）
    [self.motionManager stopAccelerometerUpdates];
    //viewDidDisappear中取消监听
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
