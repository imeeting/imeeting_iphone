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

@interface ECVideoDecode ()
- (void)handleError;
- (int)openVideoInputStream:(const char*)playPath;
- (void)readVideoFrame;
- (void)closeVideoInputStream;
- (UIImage*)imageFromAVPicture:(AVFrame*)picture width:(int)width height:(int)height;
@end

@implementation ECVideoDecode
@synthesize rtmpUrl = _rtmpUrl;
@synthesize dstImgWidth = _dstImgWidth;
@synthesize dstImgHeight = _dstImgHeight;
@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        inputFormatContext = NULL;
        dst_pix_fmt = PIX_FMT_RGB24;
        inputFormatContext = NULL;
        videoCodecContext = NULL;
        videoCodec = NULL;
        self.dstImgWidth = 144;
        self.dstImgHeight = 192;
    }
    return self;
}

- (void)setupVideoDecode {
    av_register_all();
    avformat_network_init();
    
}

- (void)releaseVideoDecode {
    avformat_network_deinit();
    [self stopFetchVideoPicture];
}

- (int)openVideoInputStream:(const char *)playPath {
    int err = avformat_open_input(&inputFormatContext, playPath, NULL, NULL);
    if (err < 0) {
        NSLog(@"ffmpeg: unable to open input");
        return -1;
    }
    
    err = avformat_find_stream_info(inputFormatContext, NULL);
    if (err < 0) {
        NSLog(@"ffmpeg: unable to find stream info");
        return -1;
    }
    
    av_dump_format(inputFormatContext, 0, playPath, 0);
    
    videoStream = -1;
    
    for (int index = 0; index < inputFormatContext->nb_streams; index++) {
        if (inputFormatContext->streams[index]->codec->codec_type == AVMEDIA_TYPE_VIDEO && videoStream < 0) {
            videoStream = index;
        }
    }
    
    if (videoStream == -1) {
        NSLog(@"ffmpeg: unable to find video stream");
        return -1;
    }
    
    videoCodecContext = inputFormatContext->streams[videoStream]->codec;
    if (!videoCodecContext) {
        NSLog(@"ffmpeg: no video codec context found");
        return -1;
    }
    // find the decoder for video stream
    videoCodec = avcodec_find_decoder(videoCodecContext->codec_id);
    if (!videoCodec) {
        NSLog(@"ffmpeg: unable to find the decoder(%d) for video stream", videoCodecContext->codec_id);
        return -1;
    }
    
    // open video stream codec
    if (avcodec_open2(videoCodecContext, videoCodec, NULL) < 0) {
        NSLog(@"ffmpeg: unable to open video codec");
        return -1;
    }
    
    return 0;
}

- (void)readVideoFrame {
    if (!inputFormatContext) {
        return;
    }
    
    AVPacket packet;
    
    // allocate a video frame to stor ethe decoded image
    videoFrame = avcodec_alloc_frame();
    if (!videoFrame) {
        NSLog(@"cannot allocate video frame");
        [self handleError];
        return;
    }
    
    
    //avpicture_alloc(videoPicture, dst_pix_fmt, self.dstImgWidth, self.dstImgHeight);
    videoPicture = alloc_picture(dst_pix_fmt, self.dstImgWidth, self.dstImgHeight);
    if (!videoPicture) {
        NSLog(@"failed to alloc video picture");
        [self handleError];
        return;
    }
    
    readFrame = YES;
    
    int gotPicture;
    while (readFrame && av_read_frame(inputFormatContext, &packet) >= 0) {
        NSLog(@"read video frame");
        // check if the packet is from video stream
        if (packet.stream_index == videoStream) {
            // Decode video frame
            avcodec_decode_video2(videoCodecContext, videoFrame, &gotPicture, &packet);
            
            if (gotPicture) {
                NSLog(@"got video picture");
                // get a video frame
                img_convert_ctx = sws_getCachedContext(img_convert_ctx, videoCodecContext->width, videoCodecContext->height, videoCodecContext->pix_fmt, self.dstImgWidth, self.dstImgHeight, dst_pix_fmt, SWS_BILINEAR, NULL, NULL, NULL);
                // convert YUV420 to RGB32
                sws_scale(img_convert_ctx, videoFrame->data, videoFrame->linesize, 0, videoCodecContext->height, videoPicture->data, videoPicture->linesize);
                
                UIImage *img = [self imageFromAVPicture:videoPicture width:self.dstImgWidth height:self.dstImgHeight];
                NSLog(@"converted image: %@", img);
                NSLog(@"delegate: %@", self.delegate);
                if (self.delegate && [self.delegate respondsToSelector:@selector(onFetchNewImage:)]) {
                    NSLog(@"have delegate - perform selector");
                    [self.delegate performSelectorOnMainThread:@selector(onFetchNewImage:) withObject:img waitUntilDone:NO];
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
    NSMutableString *playPath = [[NSMutableString alloc] initWithCapacity:20];
    NSString *myName = [[UserManager shareUserManager] userBean].name;
    [playPath appendFormat:@"%@/%@ live=1 conn=S:%@", self.rtmpUrl, username, myName];
    NSLog(@"Video play path: %@", playPath);
    
    int ret = [self openVideoInputStream:[playPath cStringUsingEncoding:NSUTF8StringEncoding]];    
    if (ret < 0) {
        NSLog(@"video input stream open failed");
        [self handleError];
        return;
    }
    
    [self readVideoFrame];
    [self closeVideoInputStream];
}

- (void)stopFetchVideoPicture {
    readFrame = NO;
}

- (void)closeVideoInputStream {
    if (videoCodecContext) {
        avcodec_close(videoCodecContext);
        videoCodecContext = NULL;
    }
    
    if (inputFormatContext) {
        avformat_close_input(&inputFormatContext);
        inputFormatContext = NULL;
    }
    
    if (videoFrame) {
        av_free(videoFrame);
        videoFrame = NULL;
    }
    
    if (videoPicture) {
        if (videoPicture->data[0]) {
            av_free(videoPicture->data[0]);
        }
        av_free(videoPicture);
        videoPicture = NULL;
    }

}

- (void)handleError {
    [self closeVideoInputStream];
}
@end
