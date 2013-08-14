//
//  HEXLeg.h
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>

#define L_AB 3.0
#define L_AA 2.9
#define Z_BC 8.0
#define L_LEG1 8.6
#define L_LEG2 14.0

@class HEXCoordinate;
@class HEXServo;

@interface HEXLeg : NSObject {
    HEXServo *_servoArray[3];
}
@property (nonatomic, strong) HEXCoordinate *origin;

- (void)gotoCoordinate:(HEXCoordinate *)coor;
- (id)initWithCoordinate:(HEXCoordinate *)coor withServoGroup:(NSArray *)sgroup;
- (NSString *)syncServo;

@end
