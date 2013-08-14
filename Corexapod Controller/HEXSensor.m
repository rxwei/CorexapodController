//
//  HEXSensor.m
//  Hexapod Controller3
//
//  Created by c0r3 on 8/10/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXSensor.h"

@implementation HEXSensor

- (id)init {
    return [self initWithName:@"N/A" withUnit:@"N/A"];
}

- (id)initWithName:(NSString *)name withUnit:(NSString *)unit {
    if (self = [super init]) {
        self.name = name;
        self.unit = unit;
        self.value = @0;
    }
    return self;
}

+ (id)sensorWithName:(NSString *)name withUnit:(NSString *)unit {
    return [[self alloc] initWithName:name withUnit:unit];
}

@end
