//
//  FilterViewController.h
//  camera
//
//  Created by TomokoTakahashi on 2015/06/17.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController {
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *boarderView;
    UIImageView *showImageView;
    UIImageView *currentStampView;
    BOOL _isPressStamp;

}

@property UIImage *image;

@end
