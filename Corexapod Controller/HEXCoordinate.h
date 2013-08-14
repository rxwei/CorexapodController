//
//  HEXCoordinate.h
//  Hexapod Controller3
//
//  Created by c0r3 on 8/1/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEXCoordinate : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;

- (id)initWithX:(float)x Y:(float)y Z:(float)z;
+ (id)coordinateWithX:(float)x Y:(float)y Z:(float)z;
- (float)dotProductWith:(HEXCoordinate *)coor;
- (HEXCoordinate *)crossProductWith:(HEXCoordinate *)coor;
- (HEXCoordinate *)multiplyWith:(float)scalar;
- (HEXCoordinate *)divideBy:(float)scalar;
- (HEXCoordinate *)subtractBy:(HEXCoordinate *)coor;
- (HEXCoordinate *)addBy:(HEXCoordinate *)coor;
- (float)module;
- (float)angleDifferenceFrom:(HEXCoordinate *)vector;

@end
