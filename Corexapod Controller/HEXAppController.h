//
//  HEXAppController.h
//  Hexapod Controller
//
//  Created by c0r3 on 7/30/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORSSerialPort.h"

@class ORSSerialPortManager;
@class HEXRobot;

//#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7)
//@protocol NSUserNotificationCenterDelegate <NSObject>
//@end
//#endif
@interface HEXAppController : NSObject <ORSSerialPortDelegate, NSUserNotificationCenterDelegate>

#pragma mark - Robot

@property (nonatomic, strong) HEXRobot *robot;
- (IBAction)action:(id)sender;

#pragma mark - Serial Port

@property (unsafe_unretained) IBOutlet NSTextField *sendTextField;
@property (unsafe_unretained) IBOutlet NSTextView *receivedDataTextView;
@property (unsafe_unretained) IBOutlet NSButton *openCloseButton;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *serialConnectIndicator;
@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) NSArray *availableBaudRates;
@property (nonatomic, strong) NSMutableString *serialBuffer;

- (IBAction)send:(id)sender;
- (IBAction)openOrClosePort:(id)sender;

#pragma mark - Sensor

@property (weak) NSTimer *sensorUpdateTimer;

#pragma mark - Test
@property (nonatomic) float xValue, yValue, zValue;
- (IBAction)generate:(id)sender;

@end
