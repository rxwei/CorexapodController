//
//  HEXCoordinate.m
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXCoordinate.h"

@implementation HEXCoordinate

- (id)initWithX:(float)x Y:(float)y Z:(float)z {
    if (self = [super init]) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

- (id)init {
    return [self initWithX:0.0 Y:0.0 Z:0.0];
}

+ (id)coordinateWithX:(float)x Y:(float)y Z:(float)z {
    return [[HEXCoordinate alloc] initWithX:x Y:y Z:z];
}

- (float)dotProductWith:(HEXCoordinate *)coor {
    return self.x * coor.x + self.y * coor.y + self.z * coor.z;
}

- (HEXCoordinate *)crossProductWith:(HEXCoordinate *)coor {
    HEXCoordinate *result = [[HEXCoordinate alloc] init];
    result.x = self.y * coor.z - self.z * coor.y;
    result.y = self.x * coor.z - self.z * coor.x;
    result.z = self.x * coor.y - self.y * coor.x;
    return result;
}

- (HEXCoordinate *)subtractBy:(HEXCoordinate *)coor {
    HEXCoordinate *result = [self copy];
    result.x -= coor.x;
    result.y -= coor.y;
    result.z -= coor.z;
    return result;
}

- (HEXCoordinate *)addBy:(HEXCoordinate *)coor {
    HEXCoordinate *result = [self copy];
    result.x += coor.x;
    result.y += coor.y;
    result.z += coor.z;
    return result;
}

- (HEXCoordinate *)multiplyWith:(float)scalar {
    HEXCoordinate *result = [self copy];
    result.x *= scalar;
    result.y *= scalar;
    result.z *= scalar;
    return result;
}

- (HEXCoordinate *)divideBy:(float)scalar {
    if (scalar == 0) {
        [NSException raise:@"Divide by zero!" format:@"%@", self];
    }
    HEXCoordinate *result = [self copy];
    result.x /= scalar;
    result.y /= scalar;
    result.z /= scalar;
    return result;
}

- (float)module {
    return sqrtf(powf(self.x, 2) + powf(self.y, 2) + powf(self.z, 2));
}

- (float)angleDifferenceFrom:(HEXCoordinate *)coor {
    return acosf([self dotProductWith:coor] / [self module]);
}

@end
