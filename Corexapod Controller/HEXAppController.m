//
//  HEXAppController.m
//  Hexapod Controller3
//
//  Created by c0r3 on 7/30/13.
//  Copyright (c) 2013 c0r3d3v. All rights reserved.
//

#import "HEXAppController.h"
#import "ORSSerialPortManager.h"
#import "HEXRobot.h"
#import "HEXSensor.h"

@implementation HEXAppController

- (id)init
{
    self = [super init];
    if (self)
	{
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
		self.availableBaudRates = [NSArray arrayWithObjects: [NSNumber numberWithInteger:300], [NSNumber numberWithInteger:1200], [NSNumber numberWithInteger:2400], [NSNumber numberWithInteger:4800], [NSNumber numberWithInteger:9600], [NSNumber numberWithInteger:14400], [NSNumber numberWithInteger:19200], [NSNumber numberWithInteger:28800], [NSNumber numberWithInteger:38400], [NSNumber numberWithInteger:57600], [NSNumber numberWithInteger:115200], [NSNumber numberWithInteger:230400],
								   nil];
        self.robot = [[HEXRobot alloc] init];
        self.robot.delegateInstance = self;
        self.serialBuffer = [[NSMutableString alloc] init];
        
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
		[nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
        
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
#endif
    }
    
    NSLog(@"App Controller init!");
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Serial Port

#pragma mark Actions

- (IBAction)send:(id)sender
{
	NSData *dataToSend = [[NSString stringWithFormat:@"%@\r\n", self.sendTextField.stringValue] dataUsingEncoding:NSUTF8StringEncoding];
	[self.robot.serialPort sendData:dataToSend];
}

- (IBAction)openOrClosePort:(id)sender
{
    [self.serialConnectIndicator startAnimation:nil];
	self.robot.serialPort.isOpen ? [self.robot.serialPort close] : [self.robot.serialPort open];
    [self.serialConnectIndicator stopAnimation:nil];
}

- (void)processSerialBuffer {
    static int segment = -1, agfMatch = 0;
    char ch;
    const char agf[3]="AGF";
    const NSRange front= {0, 1};
    static NSMutableString *value, *sensor;
    
    for (; [_serialBuffer length] != 0; [_serialBuffer deleteCharactersInRange:front]) {
        ch = [_serialBuffer characterAtIndex:0];
        switch (ch) {
            case '$':
                segment = 0;
                value = [[NSMutableString alloc] init];
                sensor = [[NSMutableString alloc] init];
                break;
                
            case ',':
                if (++segment >= 2) {
                    segment = -1;
                }
                break;
                
            case '!': /* ignore the following '&' symbol */
                if (segment == 1) {
                    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
                    NSUserNotification *userNote = [[NSUserNotification alloc] init];
                    userNote.title = @"Warning";
                    userNote.informativeText = [NSString stringWithFormat:@"Sensor #%@ encountered an error: %@", sensor, value];
                    userNote.soundName = nil;
                    [unc deliverNotification:userNote];
                }
                segment = -1;
                break;
                
            case '&':
                if (segment == 1) { /* We have 2 segments this time */
                    int sensorIndex = [sensor intValue];
                    NSNumber *numberValue = [NSNumber numberWithFloat:[value floatValue]];
                    
                    [self updateSensor:sensorIndex fromValue:numberValue];
                }
                segment = -1;
                break;
                
            default:
                if (segment >= 0 && segment < 2) {
                    switch (segment) {
                        case 0:
                            [sensor appendString:[NSString stringWithFormat:@"%c", ch]];
                            break;
                        case 1:
                            [value appendString:[NSString stringWithFormat:@"%c", ch]];
                            break;
                        default:
                            break;
                    }
                } else if(ch == agf[agfMatch]) {
                    if (++agfMatch == 3) {
                        self.robot.idle = YES;
                    }
                } else {
                    agfMatch = 0;
                }
                break;
        }
        
    }
}


#pragma mark ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Close";
    [self startUpdateTimer];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Open";
    [self stopUpdateTimer];
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([string length] == 0) return;
    [self.serialBuffer appendString:string];
    [self processSerialBuffer];
	[self.receivedDataTextView.textStorage.mutableString appendString:string];
	[self.receivedDataTextView setNeedsDisplay:YES];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
	// After a serial port is removed from the system, it is invalid and we must discard any references to it
	self.robot.serialPort = nil;
	self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, object, keyPath);
	NSLog(@"Change dictionary: %@", change);
}

#pragma mark NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[center removeDeliveredNotification:notification];
	});
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

#endif

#pragma mark Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
	NSArray *connectedPorts = [[notification userInfo] objectForKey:ORSConnectedSerialPortsKey];
	NSLog(@"Ports were connected: %@", connectedPorts);
	[self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
	NSArray *disconnectedPorts = [[notification userInfo] objectForKey:ORSDisconnectedSerialPortsKey];
	NSLog(@"Ports were disconnected: %@", disconnectedPorts);
	[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
	
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in connectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in disconnectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}


#pragma mark Properties

@synthesize sendTextField = _sendTextField;
@synthesize receivedDataTextView = _receivedDataTextView;
@synthesize openCloseButton = _openCloseButton;
@synthesize availableBaudRates = _availableBaudRates;
@synthesize serialPortManager = _serialPortManager;
- (void)setSerialPortManager:(ORSSerialPortManager *)manager
{
	if (manager != _serialPortManager)
	{
		[_serialPortManager removeObserver:self forKeyPath:@"availablePorts"];
		_serialPortManager = manager;
		NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
		[_serialPortManager addObserver:self forKeyPath:@"availablePorts" options:options context:NULL];
	}
}

#pragma mark - Sensor

- (void)startSensor:(int)index {
    [self.robot.serialPort sendData:[[NSString stringWithFormat:@"$%d\r\n", index] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)startSensorHelper:(NSTimer *)timer {
    static int idx = 0;
    if (idx++ == 3) {
        idx = 0;
    }
    [self startSensor:idx];
}

- (void)updateSensor:(int)index fromValue:(NSNumber *)value {
    ((HEXSensor *)self.robot.sensorArray[index]).value = value;
}

- (void)startUpdateTimer {
    [self.sensorUpdateTimer invalidate];
    self.sensorUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(startSensorHelper:) userInfo:nil repeats:YES];
}

- (void)stopUpdateTimer {
    [self.sensorUpdateTimer invalidate];
    self.sensorUpdateTimer = nil;
}

#pragma mark - Robot

- (IBAction)action:(id)sender {
    [self.robot actionGroup:(int)[sender tag] withCount:1];
    NSLog(@"push");
}

- (IBAction)generate:(id)sender {
}
@end
