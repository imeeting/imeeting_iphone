//
//  ECVideoDecode.m
//  imeeting_iphone
//
//  Created by star king on 12-6-28.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECVideoDecode.h"
#import "CommonToolkit/UserManager.h"
#import "AVFoundation/AVFoundation.h"
#import "quicklibav.h"

@implementation VideoFetchExecutor
@synthesize delegate = _delegate;
@synthesize imgWidth = _imgWidth;
@synthesize imgHeight = _imgHeight;
@synthesize rtmpUrl = _rtmpUrl;
@synthesize groupId = _groupId;
@synthesize username = _username;

- (id)init {
    self = [super init];
    if (self) {
        _dst_pix_fmt = PIX_FMT_RGB24;
    }
    return self;
}

- (int)openVideoInputStream:(const char *)playPath {
    int err = avformat_open_input(&_inputFormatContext, playPath, NULL, NULL);
    if (err < 0) {
        NSLog(@"ffmpeg: unable to open input");
        return -1;
    }
    
    err = avformat_find_stream_info(_inputFormatContext, NULL);
    if (err < 0) {
        NSLog(@"ffmpeg: unable to find stream info");
        return -1;
    }
    
    av_dump_format(_inputFormatContext, 0, playPath, 0);
    
    _videoStream = -1;
    
    for (int index = 0; index < _inputFormatContext->nb_streams; index++) {
        if (_inputFormatContext->streams[index]->codec->codec_type == AVMEDIA_TYPE_VIDEO && _videoStream < 0) {
            _videoStream = index;
        }
    }
    
    if (_videoStream == -1) {
        NSLog(@"ffmpeg: unable to find video stream");
        return -1;
    }
    
    _videoCodecContext = _inputFormatContext->streams[_videoStream]->codec;
    if (!_videoCodecContext) {
        NSLog(@"ffmpeg: no video codec context found");
        return -1;
    }
    // find the decoder for video stream
    _videoCodec = avcodec_find_decoder(_videoCodecContext->codec_id);
    if (!_videoCodec) {
        NSLog(@"ffmpeg: unable to find the decoder(%d) for video stream", _videoCodecContext->codec_id);
        return -1;
    }
    
    // open video stream codec
    if (avcodec_open2(_videoCodecContext, _videoCodec, NULL) < 0) {
        NSLog(@"ffmpeg: unable to open video codec");
        return -1;
    }
    
    return 0;
}

- (void)readVideoFrame {
    NSLog(@"### read video frame start");
    if (!_inputFormatContext) {
        return;
    }
    
    AVPacket packet;
    
    // allocate a video frame to store the decoded image
    _videoFrame = avcodec_alloc_frame();
    if (!_videoFrame) {
        NSLog(@"cannot allocate video frame");
        [self handleError];
        return;
    }
    
    _videoPicture = alloc_picture(_dst_pix_fmt, self.imgWidth, self.imgHeight);
    if (!_videoPicture) {
        NSLog(@"failed to alloc video picture");
        [self handleError];
        return;
    }
        
    int gotPicture;
    while (av_read_frame(_inputFormatContext, &packet) >= 0) {
        NSThread *currentThread = [NSThread currentThread];
        if (currentThread.isCancelled) {
            NSLog(@"video frame read thread is cancelled");
            break;
        }
        NSLog(@"read video frame");
        // check if the packet is from video stream
        if (packet.stream_index == _videoStream) {
            // Decode video frame
            avcodec_decode_video2(_videoCodecContext, _videoFrame, &gotPicture, &packet);
            
            if (gotPicture) {
                NSLog(@"got video picture");
                // get a video frame
                _img_convert_ctx = sws_getCachedContext(_img_convert_ctx, _videoCodecContext->width, _videoCodecContext->height, _videoCodecContext->pix_fmt, self.imgWidth, self.imgHeight, _dst_pix_fmt, SWS_BILINEAR, NULL, NULL, NULL);
                // convert YUV420 to RGB24
                sws_scale(_img_convert_ctx, _videoFrame->data, _videoFrame->linesize, 0, _videoCodecContext->height, _videoPicture->data, _videoPicture->linesize);
                @autoreleasepool {
                    UIImage *img = [self imageFromAVPicture:_videoPicture width:self.imgWidth height:self.imgHeight];
                    //    NSLog(@"delegate: %@", self.delegate);
                    if (self.delegate && [self.delegate respondsToSelector:@selector(onFetchNewImage:)]) {
                        NSLog(@"have delegate - perform selector");
                        [self.delegate performSelectorOnMainThread:@selector(onFetchNewImage:) withObject:img waitUntilDone:YES];
                    }
                }
            }
        }
    }
    
}

- (UIImage *)imageFromAVPicture:(AVFrame *)picture width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picture->data[0], width * height * 3, kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, bitmapInfo, provider, NULL, YES, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

- (void)startFetchVideoPictureWithUsername:(NSString *)username {
    if (_delegate && [_delegate respondsToSelector:@selector(onFetchVideoBeginToPrepare:)]) {
        [_delegate performSelectorOnMainThread:@selector(onFetchVideoBeginToPrepare:) withObject:username waitUntilDone:NO];
    }
    
    NSMutableString *playPath = [[NSMutableString alloc] initWithCapacity:20];
    NSString *myName = [[UserManager shareUserManager] userBean].name;
    [playPath appendFormat:@"%@/%@/%@ live=1 conn=S:%@", self.rtmpUrl, self.groupId, username, myName];
    NSLog(@"Video play path: %@", playPath);
    
    int ret = [self openVideoInputStream:[playPath cStringUsingEncoding:NSUTF8StringEncoding]];    
    if (ret < 0) {
        NSLog(@"video input stream open failed");
        [self handleError];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onFetchVideoPrepared)]) {
        [_delegate performSelectorOnMainThread:@selector(onFetchVideoPrepared) withObject:nil waitUntilDone:NO];
    }
    
    [self readVideoFrame];
    
    NSLog(@"after read video frame");
    
    if (_delegate && [_delegate respondsToSelector:@selector(onFetchEnd)]) {
        [_delegate performSelectorOnMainThread:@selector(onFetchEnd) withObject:nil waitUntilDone:YES];
    }
    
    [self closeVideoInputStream];
}

- (void)closeVideoInputStream {
    NSLog(@"close video input stream");
    self.username = nil;
    if (_videoCodecContext) {
        avcodec_close(_videoCodecContext);
        _videoCodecContext = NULL;
    }
    if (_inputFormatContext) {
        avformat_close_input(&_inputFormatContext);
        _inputFormatContext = NULL;
    }
    if (_videoFrame) {
        av_free(_videoFrame);
        _videoFrame = NULL;
    }
    if (_videoPicture) {
        if (_videoPicture->data[0]) {
            av_free(_videoPicture->data[0]);
        }
        av_free(_videoPicture);
        _videoPicture = NULL;
    }
    NSLog(@"video input stream closed");

    
}

- (void)handleError {
    [self closeVideoInputStream];
    if (_delegate && [_delegate respondsToSelector:@selector(onFetchFailed)]) {
        [_delegate performSelectorOnMainThread:@selector(onFetchFailed) withObject:nil waitUntilDone:NO];
    }
}



@end


@implementation ECVideoDecode
@synthesize rtmpUrl = _rtmpUrl;
@synthesize dstImgWidth = _dstImgWidth;
@synthesize dstImgHeight = _dstImgHeight;
@synthesize delegate = _delegate;
@synthesize groupId = _groupId;

- (id)init {
    self = [super init];
    if (self) {
        self.dstImgWidth = 144;
        self.dstImgHeight = 192;
    }
    return self;
}

- (void)setupVideoDecode {
   // av_log_set_level(AV_LOG_DEBUG);
    av_register_all();
    avformat_network_init();
    
}

- (void)releaseVideoDecode {
    [self stopFetchVideoPicture];
    sleep(0.5);
    NSLog(@"before avformat_network_deinit");
    avformat_network_deinit();
    NSLog(@"after avformat_network_deinit");
}


- (void)startFetchVideoPictureWithUsername:(NSString *)username {
    _executor = [[VideoFetchExecutor alloc] init];
    _executor.imgWidth = self.dstImgWidth;
    _executor.imgHeight = self.dstImgHeight;
    _executor.rtmpUrl = self.rtmpUrl;
    _executor.delegate = self.delegate;
    _executor.groupId = self.groupId;
    _executor.username = username;
    
    _exeThread = [[NSThread alloc] initWithTarget:_executor selector:@selector(startFetchVideoPictureWithUsername:) object:username];
    [_exeThread start];
    
}

- (NSString *)currentVideoUserName {
    if (_executor) {
        return _executor.username;
    } else {
        return nil;
    }
}

- (void)stopFetchVideoPicture {
    _executor.delegate = nil;
    [_exeThread cancel];
}

@end
