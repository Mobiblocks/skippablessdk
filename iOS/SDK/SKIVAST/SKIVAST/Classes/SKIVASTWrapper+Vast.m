
//
//  SKIVASTWrapper+Vast.m
//

#import "SKIVASTWrapper+Vast.h"

#import <objc/runtime.h>

@implementation SKIVASTWrapper (Vast)

- (SKIVASTVAST *)wrappedVast {
    return objc_getAssociatedObject(self, @selector(wrappedVast));
}

- (void)setWrappedVast:(SKIVASTVAST *)wrappedVast {
    objc_setAssociatedObject(self, @selector(wrappedVast), wrappedVast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

