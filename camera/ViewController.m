//
//  ViewController.m
//  camera
//
//  Created by TomokoTakahashi on 2015/06/03.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import "ViewController.h"
#import "FilterViewController.h"

@interface ViewController ()<UIAlertViewDelegate, DLCImagePickerDelegate>

@end

@implementation ViewController {
    UIImage *passImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [imageView setContentMode:UIViewContentModeScaleAspectFit];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)postToTwitter{
    NSString *serviceType = SLServiceTypeTwitter;
    if([SLComposeViewController isAvailableForServiceType:serviceType]){
        SLComposeViewController *twitterPostVC = [[SLComposeViewController alloc]init];
        twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [twitterPostVC setInitialText:@"LITech #TechCamera"];
        [twitterPostVC addImage:imageView.image];
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }
}


@end
