//
//  ECVideoDecode.h
//  imeeting_iphone
//
//  Created by star king on 12-6-28.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libavformat/avformat.h"
#import "libavcodec/avcodec.h"
#import "libswscale/swscale.h"
#import "ECVideoFetchDelegate.h"

@interface VideoFetchExecutor : NSObject {
    AVFormatContext *_inputFormatContext;
    AVCodecContext *_videoCodecContext;
    AVCodec *_videoCodec;
    int _videoStream;
    AVFrame *_videoFrame;
    AVFrame *_videoPicture;
    
    struct SwsContext *_img_convert_ctx;    
    enum PixelFormat _dst_pix_fmt;
}
@property (nonatomic, retain) id delegate;
@property (nonatomic) int imgWidth;
@property (nonatomic) int imgHeight;
@property (nonatomic, retain) NSString *rtmpUrl;
@property (nonatomic, retain) NSString *groupId;

- (void)startFetchVideoPictureWithUsername:(NSString*)username;
- (void)handleError;
- (int)openVideoInputStream:(const char*)playPath;
- (void)readVideoFrame;
- (void)closeVideoInputStream;
- (UIImage*)imageFromAVPicture:(AVFrame*)picture width:(int)width height:(int)height;

@end

@interface ECVideoDecode : NSObject {
    VideoFetchExecutor *_executor;
    NSThread *_exeThread;

}
@property (nonatomic,retain) NSString *rtmpUrl;
@property (nonatomic,retain) NSString *groupId;
@property (nonatomic) int dstImgWidth;
@property (nonatomic) int dstImgHeight;
@property (nonatomic,retain) id delegate;

- (void)setupVideoDecode;
- (void)releaseVideoDecode;
- (void)startFetchVideoPictureWithUsername:(NSString*)username;
- (void)stopFetchVideoPicture;
@end
