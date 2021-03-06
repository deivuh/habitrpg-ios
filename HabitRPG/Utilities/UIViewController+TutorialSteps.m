//
//  UIViewController+TutorialSteps.m
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "UIViewController+TutorialSteps.h"
#import "HRPGExplanationView.h"
#import "HRPGManager.h"
#import "TutorialSteps.h"
#import "MPCoachMarks.h"

@implementation UIViewController (TutorialSteps)

@dynamic displayedTutorialStep;
@dynamic tutorialIdentifier;
@dynamic coachMarks;

- (void)displayTutorialStep:(HRPGManager *)sharedManager {
    if (self.tutorialIdentifier && !self.displayedTutorialStep) {
        if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:self.tutorialIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", self.tutorialIdentifier];
            NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
            if (![nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                self.displayedTutorialStep = YES;
                [self displayExlanationView:self.tutorialIdentifier highlightingArea:CGRectZero withDefaults:defaults inDefaultsKey:defaultsKey];

            }
        }
    }
    
    if (self.coachMarks && !self.displayedTutorialStep) {
        for (NSString *coachMark in self.coachMarks) {
            if (![[sharedManager user] hasSeenTutorialStepWithIdentifier:coachMark]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", coachMark];
                NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
                if ([nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                    continue;
                }
                if ([self respondsToSelector:@selector(getFrameForCoachmark:)]) {
                    CGRect frame = [self getFrameForCoachmark:coachMark];
                    if (!CGRectEqualToRect(frame, CGRectZero)) {
                        self.displayedTutorialStep = YES;
                        [self displayExlanationView:coachMark highlightingArea:frame withDefaults:defaults inDefaultsKey:defaultsKey];
                    }
                }
                break;
            }
        }
    }
}

- (void)displayExlanationView:(NSString *)identifier  highlightingArea:(CGRect)frame withDefaults:(NSUserDefaults *)defaults inDefaultsKey:(NSString *)defaultsKey {
    NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:identifier];
    HRPGExplanationView *explanationView = [[HRPGExplanationView alloc] init];
    explanationView.speechBubbleText = tutorialDefinition[@"text"];
    if (!CGRectIsEmpty(frame)) {
        explanationView.highlightedFrame = frame;
    }
    [explanationView displayOnView:self.parentViewController.parentViewController.view animated:YES];
    
    explanationView.dismissAction= ^(BOOL wasSeen) {
        TutorialSteps *step = [TutorialSteps markStep:identifier asSeen:wasSeen withContext:self.sharedManager.getManagedObjectContext];
        [[self.sharedManager user] addTutorialStepsObject:step];
        if (!wasSeen) {
            //Show it again the next day
            NSDate *nextAppearance = [[NSDate date] dateByAddingTimeInterval:86400];
            [defaults setValue:nextAppearance forKey:defaultsKey];
        }
        NSError *error;
        [self.sharedManager.getManagedObjectContext saveToPersistentStore:&error];
    };
}


@end

