//
//  ECVideoManager.m
//  imeeting_iphone
//
//  Created by star king on 12-6-27.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECVideoManager.h"
#import "CommonToolkit/AVCamUtilities.h"

#ifndef STREAM_FRAME_RATE
    #define STREAM_FRAME_RATE 15
#endif

@interface ECVideoManager ()
- (void)setVideoOutputFps:(int32_t)fps AndOrientation:(AVCaptureVideoOrientation)orientation;
@end

@implementation ECVideoManager
@synthesize session = _session;
@synthesize videoDataOutput = _videoDataOutput;
@synthesize currentVideoInput = _currentVideoInput;
@synthesize currentCameraPosition = _currentCameraPosition;
@synthesize sessionPreset = _sessionPreset;
@synthesize videoEncode = _videoEncode;
@synthesize videoDecode = _videoDecode;

- (id)init {
    self = [super init];
    if (self) {
        self.sessionPreset = AVCaptureSessionPresetLow;
        self.currentCameraPosition = AVCaptureDevicePositionFront;

        self.videoEncode = [[ECVideoEncode alloc] init];
        self.videoDecode = [[ECVideoDecode alloc] init];
    }
    return self;
}

- (void)setLiveName:(NSString*)liveName {
    self.videoEncode.liveName = liveName;
}

- (void)setRtmpUrl:(NSString*)rtmpUrl {
    self.videoEncode.rtmpUrl = rtmpUrl;
    self.videoDecode.rtmpUrl = rtmpUrl;
}

- (void)setGroupId:(NSString*)groupId {
    self.videoEncode.groupId = groupId;
    self.videoDecode.groupId = groupId;
}

- (void)setOutImgWidth:(int)outImgWidth {
    self.videoEncode.outImgWidth = outImgWidth;
    self.videoDecode.dstImgWidth = outImgWidth;
}

- (void)setOutImgHeight:(int)outImgHeight {
    self.videoEncode.outImgHeight = outImgHeight;
    self.videoDecode.dstImgHeight = outImgHeight;
}

- (NSString *)liveName {
    return self.videoEncode.liveName;
}

- (NSString *)rtmpUrl {
    return self.videoEncode.rtmpUrl;
}

- (int)outImgWidth {
    return self.videoEncode.outImgWidth;
}

- (int)outImgHeight {
    return self.videoEncode.outImgHeight;
}

- (void)setVideoFetchDelegate:(id)delegate {
    self.videoDecode.delegate = delegate;
}

// switch between front and back camera
- (void)switchCamera {
    if (self.session) {
        [self.session beginConfiguration];
        
        if (self.currentCameraPosition == AVCaptureDevicePositionBack) {
            self.currentCameraPosition = AVCaptureDevicePositionFront;
        } else {
            self.currentCameraPosition = AVCaptureDevicePositionBack;
        }
        AVCaptureDevice *camera = [self cameraWithPosition:self.currentCameraPosition];
        NSError *error = nil;
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        if (newInput != nil) {
            [self.session removeInput:self.currentVideoInput];
            [self.session addInput:newInput];
            self.currentVideoInput = newInput;
            
            [self setVideoOutputFps:STREAM_FRAME_RATE AndOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [self.session commitConfiguration];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)postion {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == postion) {
            device = camera;
            break;
        }
    }
    return device;
}

- (void)setVideoOutputFps:(int32_t)fps AndOrientation:(AVCaptureVideoOrientation)orientation {
    // set video fps and orientation
    AVCaptureConnection *videoConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:self.videoDataOutput.connections];    
    if (videoConnection) {
        NSLog(@"connection found");
        videoConnection.videoMinFrameDuration = CMTimeMake(1, fps);
        if (videoConnection.isVideoOrientationSupported) {
            NSLog(@"set video orientation");
            videoConnection.videoOrientation = orientation;
        }
    }
}

// setup video capture session
- (void)setupSession {
    NSLog(@"setup video session");
    AVCaptureDevice *camera = [self cameraWithPosition:self.currentCameraPosition];
    if (!camera) {
        NSLog(@"no proper camera found!");
        return;
    }
    
    NSError *error = nil;
    self.currentVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if (!self.currentVideoInput) {
        NSLog(@"failed to get video input!");
        self.currentVideoInput = nil;
        return;
    }
    
    // init session
    self.session = [[AVCaptureSession alloc] init];
    if (!self.session) {
        NSLog(@"session init failed!");
        self.currentVideoInput = nil;
        self.session = nil;
        return;
    }
    self.session.sessionPreset = self.sessionPreset;
    [self.session addInput:self.currentVideoInput];
    
    // create and init AVCaptureVideoDataOutput and settings
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (!self.videoDataOutput) {
        NSLog(@"failed to get video data output!");
        self.videoDataOutput = nil;
        self.currentVideoInput = nil;
        self.session = nil;
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    self.videoDataOutput.videoSettings = settings;
    
    // create a serial queue to process our frames
    dispatch_queue_t queue = dispatch_queue_create("elegantcloud", NULL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    [self.session addOutput:self.videoDataOutput];
    
    [self setVideoOutputFps:STREAM_FRAME_RATE AndOrientation:AVCaptureVideoOrientationPortrait];
    
    //##### setup video decode 
    [self.videoDecode setupVideoDecode];
    
}

// start to capture video and upload
- (void)startVideoCapture {
    if (self.session) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; // keep screen always light
        [self.session startRunning];
        [NSThread detachNewThreadSelector:@selector(setupVideoEncode) toTarget:self.videoEncode withObject:nil];
    }
}

// close camera, stop video capture
- (void)stopVideoCapture {
    if (self.session) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; // enable idle timer
        [self.session stopRunning];
        [self.videoEncode releaseVideoEncode];
    }
}

- (void)releaseSession {
    [self stopVideoCapture];
    self.session = nil;
    self.currentVideoInput = nil;
    self.videoDataOutput = nil;
    
    //### release video decode
    [self.videoDecode releaseVideoDecode];
}

- (void)startVideoFetchWithTargetUsername:(NSString *)username {
    [self.videoDecode startFetchVideoPictureWithUsername:username];
}

- (void)stopVideoFetch {
    [self.videoDecode stopFetchVideoPicture];
}

#pragma mark - capture output
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
   // NSLog(@"capture output");
    
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // get information about image
        uint8_t *imgBaseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
      
        [self.videoEncode processRawFrame:imgBaseAddress andWidth:width andHeight:height];
    }
}

@end
