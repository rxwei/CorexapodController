//
//  HEXRobot.m
//  Hexapod Controller3
//
//  Created by c0r3 on 7/30/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXRobot.h"
#import "ORSSerialPort.h"
#import "HEXAppController.h"
#import "HEXSensor.h"
#import "HEXServo.h"
#import "HEXLeg.h"
#import "HEXCoordinate.h"

@implementation HEXRobot

- (id)init {
    if (self = [super init]) {
        HEXSensor *temp, *rh, *distance, *voltage;
        temp = [HEXSensor sensorWithName:@"Temperature" withUnit:@"℃"];
        rh = [HEXSensor sensorWithName:@"Humidity" withUnit:@"%"];
        distance = [HEXSensor sensorWithName:@"Distance" withUnit:@"cm"];
        voltage = [HEXSensor sensorWithName:@"Voltage" withUnit:@"V"];
        self.sensorArray = [NSArray arrayWithObjects:voltage, temp, rh, distance, nil];
        
        const int initServoData[6][4][4] = {
            {
                {23, 500, 2500, 1500}, {22, 500, 2500, 1500}, {21, 500, 2500, 1500}, //0
                {-4.0, 7.4, 0}, //x, y, z
            },
            {
                {26, 500, 2500, 1500}, {25, 500, 2500, 1500}, {24, 500, 2500, 1500}, //1
                {-6.3, 0, 0}, //x, y, z
            },
            {
                {29, 500, 2500, 1500}, {28, 500, 2500, 1500}, {27, 500, 2500, 1500}, //2
                {-4.0, -7.4, 0}, //x, y, z
            },
            {
                {4 , 500, 2500, 1500}, {5 , 500, 2500, 1500}, {6 , 500, 2500, 1500}, //3
                {4.0, -7.4, 0}, //x, y, z
            },
            {
                {7 , 500, 2500, 1500}, {8 , 500, 2500, 1500}, {9 , 500, 2500, 1500}, //4
                {6.3, 0, 0}, //x, y, z
            },
            {
                {10, 500, 2500, 1500}, {11, 510, 2411, 1500}, {12, 243, 2243, 1500}, //5
                {4.0, 7.4, 0}, //x, y, z
            },
        };
        for (int i = 0; i < 6; i++) {
            NSMutableArray *tempArray;
            for (int j = 0; j < 3; j++) {
                HEXServo *tempServo = [[HEXServo alloc] initWithMinAnglePW:initServoData[i][j][1]
                                                            withMaxAnglePW:initServoData[i][j][2]
                                                             withCurrentPW:initServoData[i][j][3]
                                                           withServoNumber:initServoData[i][j][0]];
                [tempArray addObject:tempServo];
            }
            _leg[i] = [[HEXLeg alloc]
                       initWithCoordinate:[HEXCoordinate coordinateWithX:initServoData[i][3][0] Y:initServoData[i][3][1] Z:initServoData[i][3][2]]withServoGroup:tempArray];
        }
    }
    NSLog(@"Robot init!");
    return self;
}

- (void)actionGroup:(int)group withCount:(int)count{
    if (self.idle) {
        self.idle = NO;
        [self.serialPort sendData:[[NSString stringWithFormat:@"#%dGC%d\r\n", group, count] dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)syncServo {
}

//@synthesize serialPort = _serialPort;
- (void)setSerialPort:(ORSSerialPort *)port
{
	if (port != _serialPort)
	{
		[_serialPort close];
		_serialPort.delegate = nil;
		_serialPort = port;
		_serialPort.delegate = self.delegateInstance;
	}
}

@end
