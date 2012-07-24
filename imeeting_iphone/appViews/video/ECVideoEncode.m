//
//  ECVideoEncode.m
//  imeeting_iphone
//
//  Created by star king on 12-6-28.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECVideoEncode.h"

@implementation ECVideoEncode
@synthesize outImgWidth = _outImgWidth;
@synthesize outImgHeight = _outImgHeight;
@synthesize liveName = _liveName;
@synthesize groupId = _groupId;
@synthesize rtmpUrl = _rtmpUrl;

- (id)init {
    self = [super init];
    if (self) {
        self.outImgWidth = 144;
        self.outImgHeight = 192;
        _videoEncodeReady = NO;
    }
    return self;
}

// setup video encoding related resources
- (void)setupVideoEncode {
    _qvo = (QuickVideoOutput*)malloc(sizeof(QuickVideoOutput));
    _qvo->width = self.outImgWidth;
    _qvo->height = self.outImgHeight;
    
    NSMutableString *rtmpFullPath = [[NSMutableString alloc] initWithCapacity:20];
    [rtmpFullPath appendFormat:@"%@/%@/%@ live=1 conn=S:%@", self.rtmpUrl, self.groupId, self.liveName, self.liveName];
    NSLog(@"rtmp path: %@", rtmpFullPath);
    int ret = init_quick_video_output(_qvo, [rtmpFullPath cStringUsingEncoding:NSUTF8StringEncoding], "flv");
    if (ret < 0) {
        NSLog(@"quick video output initial failed.");
        [self releaseVideoEncode];
        return;
    }
    
    enum PixelFormat dst_pix_fmt = _qvo->video_stream->codec->pix_fmt;
    _src_pix_fmt = PIX_FMT_RGB32;
    
    _raw_picture = alloc_picture(dst_pix_fmt, _qvo->width, _qvo->height);
    _tmp_picture = avcodec_alloc_frame();
    _raw_picture->pts = 0;
    
    _videoEncodeReady = YES;
}


// release video encoding related resources
- (void)releaseVideoEncode {
    _videoEncodeReady = NO;
    if (_qvo) {
        close_quick_video_ouput(_qvo);
        free(_qvo);
        _qvo = NULL;
    }
    
    if (_raw_picture) {
        if (_raw_picture->data[0]) {
            av_free(_raw_picture->data[0]);
        }
        av_free(_raw_picture);
        _raw_picture = NULL;
    }
    
    if (_tmp_picture) {
        av_free(_tmp_picture);
        _tmp_picture = NULL;
    }
}

- (void)processRawFrame: (uint8_t *)buffer_base_address andWidth: (int)width andHeight: (int)height{
   // NSLog(@"origin image width: %d height: %d", width, height);    
    
    if (!_qvo || !_videoEncodeReady) {
        return;
    }
    
    AVCodecContext *c = _qvo->video_stream->codec;
    
    avpicture_fill((AVPicture *)_tmp_picture, buffer_base_address, _src_pix_fmt, width, height);
    //NSLog(@"raw picture to encode width: %d height: %d", c->width, c->height);
    
    _img_convert_ctx = sws_getCachedContext(_img_convert_ctx, width, height, _src_pix_fmt, _qvo->width, _qvo->height, c->pix_fmt, SWS_BILINEAR, NULL, NULL, NULL);
    
    // convert RGB32 to YUV420
    sws_scale(_img_convert_ctx, _tmp_picture->data, _tmp_picture->linesize, 0, height, _raw_picture->data, _raw_picture->linesize);
    
    int out_size = write_video_frame(_qvo, _raw_picture);
    
    // NSLog(@"stream pts val: %lld time base: %d / %d",qvo->video_stream->pts.val, qvo->video_stream->time_base.num, qvo->video_stream->time_base.den);
    //double video_pts = (double)qvo->video_stream->pts.val * qvo->video_stream->time_base.num / qvo->video_stream->time_base.den;
   // NSLog(@"write video frame - size: %d video pts: %f", out_size, video_pts);
    
    _raw_picture->pts++;
    
}


@end
