//
//  TrollLoopHanlder.m
//  OSSDemo
//
//  Created by Troll on 16/1/15.
//  Copyright © 2016年 Troll. All rights reserved.
//

#import "TrollLoopHanlder.h"

@interface TrollLoopHanlder ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scv;
@property (nonatomic, strong) UIImageView *firstImv;
@property (nonatomic, strong) UIImageView *secondImv;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL canLoop;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger loopIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, assign) TrollLoopDirection direction;

@end

@implementation TrollLoopHanlder

- (instancetype)initWithFrame:(CGRect)frame inView:(UIView *)view{
    if(self = [super init]){
        _scv = [[UIScrollView alloc] initWithFrame:frame];
        _scv.delegate = self;
        _cache = [[NSCache alloc] init];
        _direction = TrollLoopDirectionLeft;
        [view addSubview:_scv];
        
    }
    return self;
}

- (void)setContentImages:(NSArray *)images{
    if(images == nil || images.count == 0) return;
    _images = images;
    _index = 0;
    _loopIndex = 0;
    if(images.count < 2){
        _canLoop = NO;
    }else{
        if(_firstImv == nil){
            _firstImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scv.frame.size.width, _scv.frame.size.height)];
            _firstImv.backgroundColor = [UIColor redColor];
            [_scv addSubview:_firstImv];
        }else{
            _firstImv.frame = CGRectMake(0, 0, _scv.frame.size.width, _scv.frame.size.height);
        }
        
        if(_secondImv == nil){
            _secondImv = [[UIImageView alloc] initWithFrame:CGRectMake(_scv.frame.size.width, 0, _scv.frame.size.width, _scv.frame.size.height)];
            _secondImv.backgroundColor = [UIColor blueColor];
            [_scv addSubview:_secondImv];
        }else{
            _secondImv.frame = CGRectMake(_scv.frame.size.width, 0, _scv.frame.size.width, _scv.frame.size.height);
        }
        
        _canLoop = YES;
    }
    
    [_scv setContentSize:CGSizeMake(_scv.frame.size.width*images.count, _scv.frame.size.height)];
    [_scv setContentOffset:CGPointMake(_index*_scv.frame.size.width, 0) animated:NO];
}

- (void)setLoopDirection:(TrollLoopDirection)direction{
    _direction = direction;
}

- (void)beginLoopWithInterval:(NSTimeInterval)timeInterval{
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(loop) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    _timer = timer;
}

- (void)loop{
    _index++;
    
    if(_direction == TrollLoopDirectionLeft){
        _loopIndex++;
    }else{
        _loopIndex--;
    }
    
    if(_index >= _images.count){
        _index = 0;
    }
    
    id obj = _images[_index];
    if([obj isKindOfClass:[NSString class]]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image_tmp = [_cache objectForKey:obj];
            if(image_tmp == nil){
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj]];
                UIImage *image = [UIImage imageWithData:imageData];

                if(image){
                    [_cache setObject:image forKey:obj];
                }
                [self setImageViewWithImage:image];
            }else{
                [self setImageViewWithImage:image_tmp];
            }
        });
    }
    [self resetSelectedImageViewAtIndex:_loopIndex];
    
    
    [_scv setContentOffset:CGPointMake(_loopIndex*_scv.frame.size.width, 0) animated:YES];
}

- (void)resetSelectedImageViewAtIndex:(NSInteger)index{
    if(index%2){
        CGFloat x;
        if(_direction == TrollLoopDirectionLeft){
            x = _firstImv.frame.size.width+_firstImv.frame.origin.x;
        }else{
            x = _firstImv.frame.origin.x-_firstImv.frame.size.width;
        }
        _secondImv.frame = CGRectMake(x, 0, _secondImv.frame.size.width, _secondImv.frame.size.height);
    }else{
        CGFloat x;
        if(_direction == TrollLoopDirectionLeft){
            x = _secondImv.frame.size.width+_secondImv.frame.origin.x;
        }else{
            x = _secondImv.frame.origin.x-_secondImv.frame.size.width;
        }
        _firstImv.frame = CGRectMake(x, 0, _firstImv.frame.size.width, _firstImv.frame.size.height);
    }
}

- (void)setImageViewWithImage:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_index%2){
            _secondImv.image = image;
        }else{
            _firstImv.image = image;
        }
    });
}

- (void)endLoop{
    [_timer invalidate];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger indexTmp = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSLog(@"index = %ld",indexTmp);
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

@end
