//
//  HEXLeg.m
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXLeg.h"
#import "HEXCoordinate.h"
#import "HEXServo.h"

@implementation HEXLeg

- (id)initWithCoordinate:(HEXCoordinate *)coor withServoGroup:(NSArray *)sgroup {
    if (self = [super init]) {
        int idx = 0;
        _origin = coor;
        for (HEXServo *servo in sgroup) {
            _servoArray[idx] = servo;
            idx++;
        }
    }
    return self;
}

- (id)init {
    [NSException raise:@"Invalid initializer is being used!" format:@"%@", self];
    return nil;
}

- (void)gotoCoordinate:(HEXCoordinate *)coor {
    /* set servo #0 */
    /* assert that _origin.z == 0 */
    HEXCoordinate *vAD = [self.origin subtractBy:coor];
    float dAngle = [self.origin angleDifferenceFrom:vAD];
    HEXCoordinate *vAz = [coor crossProductWith:self.origin];
    if (vAz.z < 0) {
        dAngle = -dAngle;
    }
    [_servoArray[0] setCurrentAngle:90.0 + dAngle];
    
    /* set servo #1 */
    HEXCoordinate *vAB = [[vAD divideBy:[vAD module]] multiplyWith:L_AB];
    HEXCoordinate *vAC = [vAB copy];
    vAC.z -= Z_BC;
    HEXCoordinate *pC = [self.origin addBy:vAC];
    float lCD = [[coor subtractBy:pC] module];
    [_servoArray[2] setCurrentAngle:acosf((powf(lCD, 2) - powf(L_LEG1, 2) - powf(L_LEG2, 2)) / (2 * L_LEG1 * L_LEG2))];
    
    /* set servo #2 */
    float zCD = fabsf(coor.z - pC.z);
    float aC = acosf(zCD / lCD);
    float aDCF = acosf((powf(L_LEG2, 2) - powf(L_LEG1, 2) - powf(lCD, 2)) / (2 * L_LEG1 * lCD));
    if (coor.z <= pC.z) {
        [_servoArray[1] setCurrentAngle:180.0 - aC - aDCF];
    } else {
        [_servoArray[1] setCurrentAngle:aC - aDCF];
    }
}

- (NSString *)syncServo {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < 3; i++) {
        [result appendString:[_servoArray[i] syncServo]];
    }
    return result;
}

@end
