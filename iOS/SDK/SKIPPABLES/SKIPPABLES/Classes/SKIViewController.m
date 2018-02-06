//
//  SKIViewController.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIViewController.h"

@interface SKIViewController ()

@property (assign, nonatomic) BOOL viewDidAppear;

@end

@implementation SKIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self addNotifications];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self addNotifications];
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.viewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	self.viewDidAppear = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	self.viewDidAppear = NO;
}

- (void)addNotifications {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[center addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
	[self applicationDidBecomeActive:self.viewDidAppear];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
	[self applicationWillResignActive:self.viewDidAppear];
}

- (void)applicationDidBecomeActive:(BOOL)previouslyVisible {
	
}

- (void)applicationWillResignActive:(BOOL)previouslyVisible {
	
}

- (void)dealloc {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
}

@end
