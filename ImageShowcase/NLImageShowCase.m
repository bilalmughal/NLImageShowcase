//
//  NLImageShowCase.m
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

#import "NLImageShowCase.h"
#import <QuartzCore/QuartzCore.h>

@implementation NLImageShowCase
@synthesize deleteMode = _deleteMode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    itemsInShowCase = [[NSMutableArray alloc] init];
    lastIndex = -1;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[self frame]];
    [self addSubview:_scrollView];
        
    _scrollView.contentMode = (UIViewContentModeScaleAspectFit);
    _scrollView.contentSize =  CGSizeMake(self.bounds.size.width,self.bounds.size.height);
    _scrollView.pagingEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.autoresizingMask = ( UIViewAutoresizingFlexibleHeight);
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1;
    _scrollView.clipsToBounds = YES;
    
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        // Ignore touch: As we do not want to handle gesture here, so pass it to NLImageShowCaseCell
        return NO;
    }
    return YES;
}

- (id)setDataSource:(id<NLImageViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _cellSize  = [_dataSource imageViewSizeInShowcase:self];
    _leftOffset = [_dataSource imageLeftOffsetInShowcase:self];
    _topOffset = [_dataSource imageTopOffsetInShowcase:self];
    _rowSpacing = [_dataSource rowSpacingInShowcase:self];
    _columnSpacing = [_dataSource columnSpacingInShowcase:self];
    _itemsInRowCount = (self.frame.size.width - _leftOffset + _columnSpacing) / (_cellSize.width + _columnSpacing);
    
    return self;
}

- (void)rearrageItems:(CGFloat)frameWidth fromIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.4 animations:
     ^{
         NLImageShowCaseCell* curCell = nil;
         NSInteger itemsCount = [itemsInShowCase count];
         int itr = index;
         for (; itr < itemsCount; itr++)
         {
             curCell = itemsInShowCase[itr];
             CGFloat newXPos = _leftOffset + (itr % _itemsInRowCount) * (_cellSize.width + _columnSpacing);
             CGFloat newYPos = _topOffset +  (itr / _itemsInRowCount) * (_cellSize.height + _rowSpacing);
             curCell.frame = CGRectMake(newXPos,newYPos,_cellSize.width,_cellSize.height);
         }
         if(itemsCount > 0)
         {
             curCell = itemsInShowCase[itemsCount-1 ];
             CGFloat scrollHeight = curCell.frame.origin.y + (_cellSize.height + _rowSpacing);
             _scrollView.contentSize =  CGSizeMake(frameWidth,scrollHeight);
         }
     }];
}

- (void) setFrame:(CGRect)frame
{
    // Call the parent class to move the view
    [super setFrame:frame];
    if(_dataSource == nil)
        _scrollView.contentSize =  CGSizeMake(frame.size.width,frame.size.height);
    else
    {
        _itemsInRowCount = (frame.size.width - _leftOffset + _columnSpacing) / (_cellSize.width + _columnSpacing);
        CGFloat frameWidth = frame.size.width;
        [self rearrageItems:frameWidth fromIndex:0];
    }
}

- (bool)addImage: (UIImage*)image
{
    NSUInteger itemCount = [itemsInShowCase count];
    NSUInteger rowCount = itemCount/_itemsInRowCount;
    CGFloat xPos = _leftOffset + (itemCount % _itemsInRowCount) * (_cellSize.width + _columnSpacing);
    CGFloat yPos = _topOffset + rowCount * (_cellSize.height + _rowSpacing);
    
    NLImageShowCaseCell* showCaseCell = [[NLImageShowCaseCell alloc] initWithFrame:CGRectMake(xPos, yPos, _cellSize.width, _cellSize.height)];
    showCaseCell.cellDelegate = self;
    
    [showCaseCell setMainImage:image];
    
    showCaseCell.index = ++lastIndex;
    showCaseCell.deleteMode = _deleteMode;
    [itemsInShowCase addObject:showCaseCell];
    
    [_scrollView addSubview:showCaseCell];
    CGFloat contentHeight = yPos+_cellSize.height + _rowSpacing;
    if(contentHeight > _scrollView.contentSize.height)
    {
        _scrollView.contentSize =  CGSizeMake(self.bounds.size.width,contentHeight);
    }
    return true;
}

-(void) setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    NSEnumerator *enumerator = [itemsInShowCase objectEnumerator];
    for (NLImageShowCaseCell *curItem in enumerator) {
        [curItem setDeleteMode:deleteMode];
    }
}

- (void) viewClicked
{
    if (_deleteMode) {
        [self setDeleteMode:false];
    }
}
- (void) deleteImage:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    NSLog(@"Deleting item with key: %d",index);
    NSInteger indexOfCell = [itemsInShowCase indexOfObject:imageShowCaseCell];
    [imageShowCaseCell removeFromSuperview];
    [itemsInShowCase removeObject:imageShowCaseCell ];
    [self rearrageItems:self.bounds.size.width fromIndex:indexOfCell];
}

- (void)imageClicked:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    [_dataSource imageClicked:self imageShowCaseCell:imageShowCaseCell];
}

- (void)imageTouchLonger:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    [_dataSource imageTouchLonger:self imageIndex:index];
    
}

@end
