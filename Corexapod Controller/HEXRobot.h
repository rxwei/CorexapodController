//
//  HEXRobot.h
//  Hexapod Controller3
//
//  Created by c0r3 on 7/30/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORSSerialPort.h"

@class ORSSerialPort;
@class HEXAppController;
@class HEXLeg;

@interface HEXRobot : NSObject {
    HEXLeg *_leg[6];
}

@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, weak) HEXAppController <ORSSerialPortDelegate, NSUserNotificationCenterDelegate> *delegateInstance;
@property (nonatomic) BOOL idle;
@property (nonatomic, strong) NSArray *sensorArray;

- (void)actionGroup:(int)group withCount:(int)count;
- (void)syncServo;

@end
