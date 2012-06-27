//
//  ECVideoCaptureManager.m
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
- (void)setupVideoEncode;
- (void)releaseVideoEncode;
- (void)setVideoOutputFps:(int32_t)fps AndOrientation:(AVCaptureVideoOrientation)orientation;
- (void)processRawFrame: (uint8_t *)buffer_base_address andWidth: (int)width andHeight: (int)height;
@end

@implementation ECVideoManager
@synthesize session = _session;
@synthesize videoDataOutput = _videoDataOutput;
@synthesize currentVideoInput = _currentVideoInput;
@synthesize currentCameraPosition = _currentCameraPosition;
@synthesize sessionPreset = _sessionPreset;
@synthesize liveName = _liveName;
@synthesize rtmpUrl = _rtmpUrl;
@synthesize outImgWidth = _outImgWidth;
@synthesize outImgHeight = _outImgHeight;

- (id)init {
    self = [super init];
    if (self) {
        self.sessionPreset = AVCaptureSessionPresetLow;
        self.currentCameraPosition = AVCaptureDevicePositionFront;
        self.outImgWidth = 144;
        self.outImgHeight = 192;
    }
    return self;
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
    
    
    //###### video encode setup
   // [self setupVideoEncode];
}

// setup video encoding related resources
- (void)setupVideoEncode {
    qvo = (QuickVideoOutput*)malloc(sizeof(QuickVideoOutput));
    qvo->width = self.outImgWidth;
    qvo->height = self.outImgHeight;
    
    NSMutableString *rtmpFullPath = [[NSMutableString alloc] initWithCapacity:20];
    [rtmpFullPath appendFormat:@"%@/%@ live=1 conn=S:%@", self.rtmpUrl, self.liveName, self.liveName];
    NSLog(@"rtmp path: %@", rtmpFullPath);
    int ret = init_quick_video_output(qvo, [rtmpFullPath cStringUsingEncoding:NSUTF8StringEncoding], "flv");
    if (ret < 0) {
        NSLog(@"quick video output initial failed.");
        [self releaseVideoEncode];
        return;
    }
    
    enum PixelFormat dst_pix_fmt = qvo->video_stream->codec->pix_fmt;
    src_pix_fmt = PIX_FMT_RGB32;
    
    raw_picture = alloc_picture(dst_pix_fmt, qvo->width, qvo->height);
    tmp_picture = avcodec_alloc_frame();
    raw_picture->pts = 0;
        
}

// start to capture video and upload
- (void)startVideoCapture {
    if (self.session) {
        [self setupVideoEncode];
        [self.session startRunning];
    }
}

// close camera, stop video capture
- (void)stopVideoCapture {
    if (self.session) {
        [self.session stopRunning];
        [self releaseVideoEncode];
    }
}

- (void)releaseSession {
    [self stopVideoCapture];
    self.session = nil;
    self.currentVideoInput = nil;
    self.videoDataOutput = nil;
    
    //[self releaseVideoEncode];
}

// release video encoding related resources
- (void)releaseVideoEncode {
    if (qvo) {
        close_quick_video_ouput(qvo);
        free(qvo);
        qvo = NULL;
    }
    
    if (raw_picture) {
        if (raw_picture->data[0]) {
            av_free(raw_picture->data[0]);
        }
        av_free(raw_picture);
        raw_picture = NULL;
    }
    
    if (tmp_picture) {
        av_free(tmp_picture);
        tmp_picture = NULL;
    }
}

#pragma mark - capture output
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"capture output");
    
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // get information about image
        uint8_t *imgBaseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
                
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        [self processRawFrame:imgBaseAddress andWidth:width andHeight:height];
    }
}

- (void)processRawFrame: (uint8_t *)buffer_base_address andWidth: (int)width andHeight: (int)height{
    NSLog(@"origin image width: %d height: %d", width, height);    
    
    if (!qvo) {
        return;
    }

    AVCodecContext *c = qvo->video_stream->codec;
    
    avpicture_fill((AVPicture *)tmp_picture, buffer_base_address, src_pix_fmt, width, height);
    NSLog(@"raw picture to encode width: %d height: %d", c->width, c->height);
    
    img_convert_ctx = sws_getCachedContext(img_convert_ctx, width, height, src_pix_fmt, qvo->width, qvo->height, c->pix_fmt, SWS_BILINEAR, NULL, NULL, NULL);
    
    // convert RGB32 to YUV420
    sws_scale(img_convert_ctx, tmp_picture->data, tmp_picture->linesize, 0, height, raw_picture->data, raw_picture->linesize);
    
    int out_size = write_video_frame(qvo, raw_picture);
    
    // NSLog(@"stream pts val: %lld time base: %d / %d",qvo->video_stream->pts.val, qvo->video_stream->time_base.num, qvo->video_stream->time_base.den);
    double video_pts = (double)qvo->video_stream->pts.val * qvo->video_stream->time_base.num / qvo->video_stream->time_base.den;
    NSLog(@"write video frame - size: %d video pts: %f", out_size, video_pts);
    
    raw_picture->pts++;
    
}


@end
