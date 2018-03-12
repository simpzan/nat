//
//  ViewController.m
//  NAT-iOS
//
//  Created by simpzan on 12/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@end

@implementation ViewController
- (IBAction)toggleSwitch:(id)sender {
    NSLog(@"toggle");
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
