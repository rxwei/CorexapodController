//
//  HEXServo.m
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXServo.h"

@implementation HEXServo

/* dedicated initializer */
- (id)initWithMinAnglePW:(int)minPW withMaxAnglePW:(int)maxPW withCurrentPW:(int)curPW withServoNumber:(int)number{
    if (self = [super init]) {
        _minAnglePW = minPW;
        _maxAnglePW = maxPW;
        _currentPW = curPW;
        _servoNumber = number;
        _stateHasChanged = YES;
    }
    return self;
}

- (id)init {
    return [self initWithMinAnglePW:DEFAULT_MIN_WIDTH withMaxAnglePW:DEFAULT_MAX_WIDTH withCurrentPW:DEFAULT_INIT_WIDTH withServoNumber:DEFAULT_INIT_NUM];
}

- (id)initWithMinAnglePW:(int)minPW withMaxAnglePW:(int)maxPW withCurrentAngle:(float)curAngle withServoNumber:(int)number{
    HEXServo *result;
    result = [self initWithMinAnglePW:minPW withMaxAnglePW:maxPW withCurrentPW:0 withServoNumber:number];
    [result setCurrentAngle:curAngle];
    return result;
}

- (void)setCurrentAngle:(float)currentAngle {
    if (currentAngle < 0.0 || currentAngle > 180.0) {
        [NSException raise:@"Current angle is invalid!" format:@"%f", currentAngle];
    } else {
        _currentAngle = currentAngle;
        if (_minAnglePW <= _maxAnglePW) {
            _currentPW = _minAnglePW + (float)(_maxAnglePW - _minAnglePW) * currentAngle / 180.0;
        } else {
            _currentPW = _minAnglePW - (float)(_maxAnglePW - _minAnglePW) * currentAngle / 180.0;
        }
    }
}

- (NSString *)syncServo {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    if (_stateHasChanged) {
        [result appendString:[NSString stringWithFormat:@"#%dP%d", _servoNumber, _currentPW]];
        _stateHasChanged = NO;
    }
    return result;
}

@end
