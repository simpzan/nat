//
//  AppDelegate.m
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
}

@property (weak) IBOutlet NSButtonCell *toggleSwitch;
@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)toggle:(id)sender {
    NSLog(@"state %ld", self.toggleSwitch.state);
}


@end
