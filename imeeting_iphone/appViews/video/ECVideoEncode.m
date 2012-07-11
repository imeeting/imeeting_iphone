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
@synthesize rtmpUrl = _rtmpUrl;

- (id)init {
    self = [super init];
    if (self) {
        self.outImgWidth = 144;
        self.outImgHeight = 192;
    }
    return self;
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

- (void)processRawFrame: (uint8_t *)buffer_base_address andWidth: (int)width andHeight: (int)height{
   // NSLog(@"origin image width: %d height: %d", width, height);    
    
    if (!qvo) {
        return;
    }
    
    AVCodecContext *c = qvo->video_stream->codec;
    
    avpicture_fill((AVPicture *)tmp_picture, buffer_base_address, src_pix_fmt, width, height);
    //NSLog(@"raw picture to encode width: %d height: %d", c->width, c->height);
    
    img_convert_ctx = sws_getCachedContext(img_convert_ctx, width, height, src_pix_fmt, qvo->width, qvo->height, c->pix_fmt, SWS_BILINEAR, NULL, NULL, NULL);
    
    // convert RGB32 to YUV420
    sws_scale(img_convert_ctx, tmp_picture->data, tmp_picture->linesize, 0, height, raw_picture->data, raw_picture->linesize);
    
    int out_size = write_video_frame(qvo, raw_picture);
    
    // NSLog(@"stream pts val: %lld time base: %d / %d",qvo->video_stream->pts.val, qvo->video_stream->time_base.num, qvo->video_stream->time_base.den);
    //double video_pts = (double)qvo->video_stream->pts.val * qvo->video_stream->time_base.num / qvo->video_stream->time_base.den;
   // NSLog(@"write video frame - size: %d video pts: %f", out_size, video_pts);
    
    raw_picture->pts++;
    
}


@end
