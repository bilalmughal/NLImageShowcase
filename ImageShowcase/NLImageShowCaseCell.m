//
//  NLImageShowCaseCell.m
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

#import "NLImageShowCaseCell.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

@implementation NLImageShowCaseCell

@synthesize index = _index;
@synthesize image = _image;
@synthesize cellDelegate = _cellDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CGFloat delButtonSize = 60;
    
    _deleteMode = NO;
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, delButtonSize, delButtonSize)];
    _deleteButton.center = CGPointMake(0, 0);
    _deleteButton.backgroundColor = [UIColor clearColor];
    
    [_deleteButton setImage: [UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    _deleteButton.hidden = YES;
    
    _mainImage = [[UIButton alloc] initWithFrame:self.bounds];
    
    [self addSubview:_mainImage];
    
    [self addSubview:_deleteButton];
    
    _mainImage.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _mainImage.imageView.layer.shadowOffset = CGSizeMake(3, 3);
    _mainImage.imageView.layer.shadowOpacity = 0.6;
    _mainImage.imageView.layer.shadowRadius = 1.0;
    _mainImage.imageView.clipsToBounds = NO;
    _mainImage.userInteractionEnabled = YES;
    
    [_mainImage addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];

    [_deleteButton addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
    [_mainImage addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [_mainImage addTarget:self action:@selector(touchCancel) forControlEvents:UIControlEventTouchUpOutside];

    return self;
}

- (id)initWithImage:(UIImage*)image
{
    return [self setMainImage:image];
}

-(void) setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    if(deleteMode)
    {
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [anim setToValue:[NSNumber numberWithFloat:0.0f]];
        [anim setFromValue:[NSNumber numberWithDouble:M_PI/64]];
        [anim setDuration:0.1];
        [anim setRepeatCount:NSUIntegerMax];
        [anim setAutoreverses:YES];
        self.layer.shouldRasterize = YES;
        [self.layer addAnimation:anim forKey:@"SpringboardShake"];
        //_mainImage.userInteractionEnabled = NO;
        _deleteButton.hidden = NO;
    }
    else
    {
        [self.layer removeAllAnimations];
        //_mainImage.userInteractionEnabled = YES;
        _deleteButton.hidden = YES;
    }
}

- (void)resetView
{
    [self.layer removeAllAnimations];
//    self.userInteractionEnabled = YES;
    [self setDeleteMode:NO];
}

- (id)setMainImage:(UIImage*)image{
    _image = image;
    //[_mainImage setImage:[self getThumbnail:image ] forState:UIControlStateNormal];
    [_mainImage setImage:image forState:UIControlStateNormal]; 
    return self;
}

- (UIImage*)getThumbnail:(UIImage*) image
{
    float imgWidth = image.size.width;
    float imgHeight = image.size.height;
    
    float width = self.bounds.size.width*(isRetina ? 2.0f : 1.0f);
    float height = self.bounds.size.height*(isRetina ? 2.0f : 1.0f);
    
    float horz =  imgWidth / width;
    float vert =  imgHeight / height;

    
    float x1 = 0,x2 = 0,y1 = 0,y2 = 0;
    
    float scalingFactor = vert < horz ? vert * (isRetina ? 2.0f : 1.0f) : horz * (isRetina ? 2.0f : 1.0f);
    
    UIImage* resizedImage = [self resizeImage:image resizeSize:CGSizeMake(imgWidth/scalingFactor, imgHeight/scalingFactor)];
    
    if(vert < horz)
    {
        x1 = (imgWidth/vert)/2 - width/2;
        x2 = (imgWidth/vert)/2 + width/2;
        y1 = 0;
        y2 = imgHeight / vert;
    }
    else if(horz < vert)
    {
        x1 = 0;
        x2 = imgWidth / horz;
        y1 = (imgHeight/horz)/2 - height/2;
        y2 = (imgHeight/horz)/2 + height/2;
    }
    else //Horz == vert
    {
        x1 = 0;
        x2 = imgWidth / horz;
        y1 = 0;
        x2 = imgHeight / vert;
    }
    
    CGRect imageRect = CGRectMake(x1, y1, x2 - x1, y2 - y1);
    CGImageRef imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:resizedImage.scale
                                    orientation:resizedImage.imageOrientation];
    CGImageRelease(imageRef);    
    return result;
}

- (UIImage *)resizeImage:(UIImage*)image resizeSize:(CGSize)resizeSize {
    CGImageRef refImage = image.CGImage;
    CGRect resizedRect = CGRectIntegral(CGRectMake(0, 0, resizeSize.width, resizeSize.height));
    UIGraphicsBeginImageContextWithOptions(resizeSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform vertFlip = CGAffineTransformMake(1, 0, 0, -1, 0, resizeSize.height);
    CGContextConcatCTM(context, vertFlip);
    CGContextDrawImage(context, resizedRect, refImage);
    CGImageRef resizedRefImage = CGBitmapContextCreateImage(context);
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedRefImage];
    CGImageRelease(resizedRefImage);
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


- (IBAction)buttonClicked {
    if(_deleteMode)
        return;
    [_timer invalidate];
    [_cellDelegate imageClicked:self imageIndex:_index];
}
- (IBAction) deleteImage {
    [_cellDelegate deleteImage:self imageIndex:_index];
    [_timer invalidate];
}

- (IBAction)touchCancel {
    [_timer invalidate];
}

- (IBAction)touchDown {
    if(_deleteMode)
        return;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(imagePushedLonger)
                                            userInfo:nil
                                             repeats:YES];
}
- (IBAction)imagePushedLonger
{
    [_timer invalidate];
    [_cellDelegate imageTouchLonger:self imageIndex:_index];
}

@end
