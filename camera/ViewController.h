//
//  ViewController.h
//  camera
//
//  Created by TomokoTakahashi on 2015/06/03.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "PhotoViewController.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate>
{
IBOutlet UIImageView *imageView;
}
-(IBAction)takePhoto;
-(IBAction)openLibrary;
-(IBAction)postToTwitter;
-(IBAction)postToFacebook;
-(IBAction)postToLINE;


@end

