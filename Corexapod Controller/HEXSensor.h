//
//  HEXSensor.h
//  Hexapod Controller3
//
//  Created by c0r3 on 8/10/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEXSensor : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *value;
@property (strong, nonatomic) NSString *unit;

- (id)initWithName:(NSString *)name withUnit:(NSString *)unit;
+ sensorWithName:(NSString *)name withUnit:(NSString *)unit;

@end
