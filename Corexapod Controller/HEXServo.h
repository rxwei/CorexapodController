//
//  HEXServo.h
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MIN_WIDTH 500
#define DEFAULT_MAX_WIDTH 2500
#define DEFAULT_INIT_WIDTH 1500
#define DEFAULT_INIT_NUM 1

@interface HEXServo : NSObject

@property (nonatomic) float currentAngle;
@property (nonatomic) int minAnglePW;
@property (nonatomic) int maxAnglePW;
@property (nonatomic) int currentPW;
@property (nonatomic) int servoNumber;
@property (nonatomic) BOOL stateHasChanged;

- (id)initWithMinAnglePW:(int)minPW withMaxAnglePW:(int)maxPW withCurrentPW:(int)curPW withServoNumber:(int)number;
- (id)initWithMinAnglePW:(int)minPW withMaxAnglePW:(int)maxPW withCurrentAngle:(float)curAngle withServoNumber:(int)number;
- (NSString *)syncServo;
- (void)setCurrentAngle:(float)currentAngle;

@end