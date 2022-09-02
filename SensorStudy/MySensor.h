//
//  MySensor.h
//  SensorStudy
//
//  Created by Dio Brand on 2022/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MySensor : NSObject

+(instancetype)sharedManager;

-(void)shake_hook;

@end

NS_ASSUME_NONNULL_END
