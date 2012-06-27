//
//  ECVideoManager.h
//  imeeting_iphone
//
//  Created by star king on 12-6-27.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "quicklibav.h"
#import "libswscale/swscale.h"

@interface ECVideoManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    QuickVideoOutput *qvo;
    AVFrame *raw_picture;
    AVFrame *tmp_picture;
    struct SwsContext *img_convert_ctx;    
    enum PixelFormat src_pix_fmt;
}

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *currentVideoInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (readwrite) AVCaptureDevicePosition currentCameraPosition;
@property (nonatomic,retain) NSString *sessionPreset;

@property (nonatomic,retain) NSString *rtmpUrl;
@property (nonatomic,retain) NSString *liveName;

@property (readwrite) int outImgWidth;
@property (readwrite) int outImgHeight;

- (void)switchCamera;
- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)postion;
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)setupSession;
- (void)releaseSession;

@end
