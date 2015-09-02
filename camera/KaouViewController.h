//
//  KaouViewController.h
//  camera
//
//  Created by TomokoTakahashi on 2015/08/24.
//  Copyright (c) 2015年 高橋知子. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KaouViewController : UIViewController {
    IBOutlet UIImageView *imageView;
    UISlider *sl;
    UILabel *lb;
}

@property(nonatomic)UIImage *passedImage;
@property (nonatomic, retain) IBOutlet UISlider *sl;
@property (nonatomic, retain) IBOutlet UILabel *lb;

- (IBAction)SliderChanged:(id)sender;


@end

