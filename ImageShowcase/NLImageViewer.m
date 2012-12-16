//
//  NLImageViewer.m
//  ImageShowcase
//
// Copyright © 2012, Mirza Bilal (bilal@mirzabilal.com)
// All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 1.	Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
// 2.	Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
// 3.	Neither the name of Mirza Bilal nor the names of its contributors may be used
//       to endorse or promote products derived from this software without specific
//       prior written permission.
// THIS SOFTWARE IS PROVIDED BY MIRZA BILAL "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MIRZA BILAL BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NLImageViewer.h"
#import <QuartzCore/QuartzCore.h>

#define IMAGE_BOUNDRY_SPACE 10

@implementation NLImageViewer
@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [self addSubview:_imageView];
    }

    return self;
}

-(void) setImage:(UIImage *)image
{
    _image = image;
    [_imageView setImage:image];
    [self reLayoutView];
    
}
-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(_image != nil)
       [self reLayoutView];
}

- (void) reLayoutView
{
    float imgWidth = _image.size.width;
    float imgHeight = _image.size.height;
    float viewWidth = self.bounds.size.width - 2*IMAGE_BOUNDRY_SPACE;
    float viewHeight = self.bounds.size.height - 2*IMAGE_BOUNDRY_SPACE;
    
    float widthRatio = imgWidth / viewWidth;
    float heightRatio = imgHeight / viewHeight;
    _scalingFactor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    _imageView.bounds = CGRectMake(0, 0, imgWidth / _scalingFactor, imgHeight/_scalingFactor);
    _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _imageView.layer.shadowOffset = CGSizeMake(3, 3);
    _imageView.layer.shadowOpacity = 0.6;
    _imageView.layer.shadowRadius = 1.0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
