//
//  M80AttributedLabelAttachment.m
//  M80AttributedLabel
//
//  Created by amao on 13-8-31.
//  Copyright (c) 2013年 www.xiangwangfeng.com. All rights reserved.
//

#import "M80AttributedLabelAttachment.h"

void deallocCallback(void* ref)
{
    M80AttributedLabelAttachment *image = (__bridge_transfer M80AttributedLabelAttachment *)(ref);
    image = nil; // release
}

CGFloat ascentCallback(void *ref)
{
    M80AttributedLabelAttachment *image = (__bridge M80AttributedLabelAttachment *)ref;
    if (![image isKindOfClass: [M80AttributedLabelAttachment class]]) {
        return 0;
    }
    
    CGFloat ascent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case M80ImageAlignmentTop:
            ascent = image.fontAscent;
            break;
        case M80ImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            ascent = height / 2 + baseLine;
        }
            break;
        case M80ImageAlignmentBottom:
            ascent = height - image.fontDescent;
            break;
        default:
            break;
    }
    return ascent;
}

CGFloat descentCallback(void *ref)
{
    M80AttributedLabelAttachment *image = (__bridge M80AttributedLabelAttachment *)ref;
    if (![image isKindOfClass: [M80AttributedLabelAttachment class]]) {
        return 0;
    }
    
    CGFloat descent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case M80ImageAlignmentTop:
        {
            descent = height - image.fontAscent;
            break;
        }
        case M80ImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            descent = height / 2 - baseLine;
        }
            break;
        case M80ImageAlignmentBottom:
        {
            descent = image.fontDescent;
            break;
        }
        default:
            break;
    }
    
    return descent;

}

CGFloat widthCallback(void* ref)
{
    M80AttributedLabelAttachment *image  = (__bridge M80AttributedLabelAttachment *)ref;
    if (![image isKindOfClass: [M80AttributedLabelAttachment class]]) {
        return 0;
    }
    
    return [image boxSize].width;
}

#pragma mark - M80AttributedLabelImage
@interface M80AttributedLabelAttachment ()
- (CGSize)calculateContentSize;
- (CGSize)attachmentSize;
@end

@implementation M80AttributedLabelAttachment




+ (M80AttributedLabelAttachment *)attachmentWith:(id)content
                                          margin:(UIEdgeInsets)margin
                                       alignment:(M80ImageAlignment)alignment
                                         maxSize:(CGSize)maxSize
{
    M80AttributedLabelAttachment *attachment    = [[M80AttributedLabelAttachment alloc]init];
    attachment.content                          = content;
    attachment.margin                           = margin;
    attachment.alignment                        = alignment;
    attachment.maxSize                          = maxSize;
    return attachment;
}


- (CGSize)boxSize
{
    CGSize contentSize = [self attachmentSize];
    if (_maxSize.width > 0 &&_maxSize.height > 0 &&
        contentSize.width > 0 && contentSize.height > 0)
    {
        contentSize = [self calculateContentSize];
    }
    return CGSizeMake(contentSize.width + _margin.left + _margin.right,
                      contentSize.height+ _margin.top  + _margin.bottom);
}


#pragma mark - 辅助方法
- (CGSize)calculateContentSize
{
    CGSize attachmentSize   = [self attachmentSize];
    CGFloat width           = attachmentSize.width;
    CGFloat height          = attachmentSize.height;
    CGFloat newWidth        = _maxSize.width;
    CGFloat newHeight       = _maxSize.height;
    if (width <= newWidth &&
        height<= newHeight)
    {
        return attachmentSize;
    }
    CGSize size;
    if (width / height > newWidth / newHeight)
    {
        size = CGSizeMake(newWidth, newWidth * height / width);
    }
    else
    {
        size = CGSizeMake(newHeight * width / height, newHeight);
    }
    return size;
}

- (CGSize)attachmentSize
{
    CGSize size = CGSizeZero;
    if ([_content isKindOfClass:[UIImage class]])
    {
        size = [((UIImage *)_content) size];
    }
    else if ([_content isKindOfClass:[UIView class]])
    {
        size = [((UIView *)_content) bounds].size;
    }
    return size;
}


- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) one = [self.class new];
    one.content = self.content;
    one.margin = self.margin;
    one.alignment = self.alignment;
    one.fontAscent = self.fontAscent;
    one.fontDescent = self.fontDescent;
    one.maxSize = self.maxSize;
    return one;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:_content forKey:@"content"];
    [coder encodeUIEdgeInsets:_margin forKey:@"margin"];
    [coder encodeObject:@(_alignment) forKey:@"alignment"];
    [coder encodeObject:@(_fontAscent) forKey:@"fontAscent"];
    [coder encodeObject:@(_fontDescent) forKey:@"fontDescent"];
    [coder encodeCGSize:_maxSize forKey:@"maxSize"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    _content = [coder decodeObjectForKey:@"content"];
    _margin = [coder decodeUIEdgeInsetsForKey:@"_margin"];
    _alignment = ((NSNumber *)[coder decodeObjectForKey:@"alignment"]).integerValue;
    _fontAscent = ((NSNumber *)[coder decodeObjectForKey:@"fontAscent"]).floatValue;
    _fontDescent = ((NSNumber *)[coder decodeObjectForKey:@"fontDescent"]).floatValue;
    _maxSize = [coder decodeCGSizeForKey:@"maxSize"];
    return self;
}

@end
