//
//  ECGroupVideoView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECBaseUIView.h"

@interface ECGroupVideoView : ECBaseUIView {
    UIImageView *mMyVideoView;
    UIImageView *mOppositeVideoView;
    
    UIButton *mLeaveGroupButton;
    UIButton *mOpenCameraButton;
}

@end
