//
//  ECVideoManager.h
//  imeeting_iphone
//
//  Created by star king on 12-6-27.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "ECVideoEncode.h"
#import "ECVideoDecode.h"

@interface ECVideoManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *currentVideoInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (readwrite) AVCaptureDevicePosition currentCameraPosition;
@property (nonatomic,retain) NSString *sessionPreset;

@property (nonatomic,retain) NSString *rtmpUrl;
@property (nonatomic,retain) NSString *liveName;
@property (nonatomic) int outImgWidth;
@property (nonatomic) int outImgHeight;

@property (nonatomic,retain) ECVideoEncode *videoEncode;
@property (nonatomic,retain) ECVideoDecode *videoDecode;

- (void)switchCamera;
- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)postion;
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)setupSession;
- (void)releaseSession;
- (void)setVideoFetchDelegate:(id)delegate;
- (void)startVideoFetchWithTargetUsername:(NSString*)username;
- (void)stopVideoFetch;
- (void)setGroupId:(NSString*)groupId;
@end
