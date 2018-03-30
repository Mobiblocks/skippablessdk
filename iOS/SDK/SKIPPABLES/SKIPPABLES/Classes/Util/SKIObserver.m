//
//  SKIObserver.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIObserver.h"

#import "SKIConstants.h"

@interface SKIObserver () {
	dispatch_source_t _timer;
}

@property (strong, nonatomic) SKIObserver *observer;

@property (assign, atomic) BOOL observing;

@property (weak, nonatomic) NSObject *object;
@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) SKIObserverCallback callback;
@property (copy, nonatomic) SKIObserverTimeoutCallback timeout;

@property (assign, nonatomic) NSTimeInterval timeoutInterval;

@end

@implementation SKIObserver

+ (instancetype)observeObject:(NSObject *)object forKeyPath:(NSString *)keyPath callback:(SKIObserverCallback)callback timeout:(SKIObserverTimeoutCallback)timeout {
	return [self observeObject:object forKeyPath:keyPath timeout:5 callback:callback timeout:timeout];
}

+ (instancetype)observeObject:(NSObject *)object
                   forKeyPath:(NSString *)keyPath
                      timeout:(NSTimeInterval)timeoutInterval
                     callback:(SKIObserverCallback)callback
					  timeout:(SKIObserverTimeoutCallback)timeout {
	SKIObserver *observer = [[SKIObserver alloc] init];
	observer.object = object;
	observer.keyPath = keyPath;
	observer.callback = callback;
	observer.timeout = timeout;
	observer.timeoutInterval = timeoutInterval;
	
	[observer addObserver];
	[observer startTimer];
	
	return observer;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.observer = self;
	}
	return self;
}

- (void)addObserver {
	if (self.observing) {
		return;
	}
	self.observing = YES;
	
	[self.object addObserver:self
				  forKeyPath:self.keyPath
					 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial)
					 context:nil];
}

- (void)removeObserver {
	if (!self.observing) {
		return;
	}
	self.observing = NO;
	[self.object removeObserver:self forKeyPath:self.keyPath];
}

- (void)startTimer {
	[self invalidateTimer];
	
	if (!self.callback) {
		return;
	}
	
	__weak typeof(self) wSelf = self;
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	dispatch_source_set_timer(_timer,
							  dispatch_time(DISPATCH_TIME_NOW, self.timeoutInterval * NSEC_PER_SEC),
							  DISPATCH_TIME_FOREVER, 0);
	
	dispatch_source_t bTimer = _timer;
	dispatch_source_set_event_handler(_timer, ^{
		[wSelf handleTimeout];
		
		if (bTimer != NULL) {
			dispatch_source_cancel(bTimer);
		}
	});
	
	dispatch_resume(_timer);
}

- (void)restartTimer {
	DLog(@"restartTimer");
	
	if (self.callback) {
		DLog(@"restartTimer callback");
		[self startTimer];
	}
}

- (void)invalidateTimer {
	if (_timer == NULL) {
		return;
	}
	
	dispatch_source_cancel(_timer);
	_timer = NULL;
}

- (void)handleTimeout {
	DLog(@"handleTimeout");
	[self invalidateTimer];
	[self removeObserver];
	if (self.timeout) {
		self.timeout(self);
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
	if (self.object == object && [self.keyPath isEqualToString:keyPath]) {
		[self invalidateTimer];
		self.callback(self, change);
		[self startTimer];
	}
}

- (void)remove {
	DLog(@"remove");
	[self invalidateTimer];
	[self removeObserver];
	
	self.callback = nil;
	self.timeout = nil;
	self.observer = nil;
	self.object = nil;
}

- (void)dealloc {
	if (_timer != NULL) {
		dispatch_source_cancel(_timer);
	}
}

@end
