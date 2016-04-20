//
// Created by Nickolay Sheika on 3/15/16.
// Copyright (c) 2016 Nickolay Sheika. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextView+APValidators.h"
#import "APValidator.h"



@implementation UITextView (APValidators)


#pragma mark - Lifecycle

- (void)dealloc
{
    [self ap_removeObserving];
}

#pragma mark - Accessors

- (APValidator *)validator
{
    return objc_getAssociatedObject(self, @selector(validator));
}

- (void)setValidator:(APValidator *)validator
{
    objc_setAssociatedObject(self, @selector(validator), validator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    validator.control = self;
    validator.validationObject = self.text;

    [self ap_removeObserving];

    [self addObserver:self
           forKeyPath:@"text"
              options:NSKeyValueObservingOptionNew
              context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ap_textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isEqual:self] && [keyPath isEqualToString:@"text"]) {
        [self ap_validate];
    }
}

#pragma mark - Notifications

- (void)ap_textViewDidChange:(NSNotification *)notification
{
    [self ap_validate];
}

#pragma mark - Private

- (void)ap_removeObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    @try {
        [self removeObserver:self forKeyPath:@"text"];
    }
    @catch (id anException) {
        // do nothing
    }
}

- (void)ap_validate
{
    self.validator.validationObject = self.text;
    [self.validator validate];
}

@end