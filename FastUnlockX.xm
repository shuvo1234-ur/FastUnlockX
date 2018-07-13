//
//  FastUnlockX.xm
//  FastUnlockX
//
//  Created by Juan Carlos Perez on 01/19/2018.
//  Copyright © 2017 CP Digital Darkroom. All rights reserved.
//

#import "FastUnlockX.h"

BOOL settingsValueFor(NSString *prefKey) {
    return [(id)CFPreferencesCopyAppValue((CFStringRef)prefKey, CFSTR("com.cpdigitaldarkroom.fastunlockx")) boolValue];
}

%hook SBDashBoardViewController

%property (assign, nonatomic) BOOL fux_alreadyAuthenticated;

- (void)viewWillAppear:(BOOL)animated {

    %orig;

    /*
    * There are two ways the lockscreen is shown. When waking the device and also when
    * pulling the notification center  down. When viewWillAppear: is called we can determine
    * if the presentation was manual since the controller will already be authenticated.
    */
    self.fux_alreadyAuthenticated = self.authenticated;
}

/*
 * Use this to catch when FaceID successfully matches
 */
- (void)setAuthenticated:(BOOL)authenticated {

    %orig;

    if(authenticated) {

        /*
         * If FUX is enabled
         */
        if(settingsValueFor(@"FUXEnabled")) {

            /*
             * Only continue with FUX if not already authenticated
             * If already authenticated we manually invoked the cover sheet and want to be there.
             */
            if(!self.fux_alreadyAuthenticated) {

                /*
                 * Flashlight Levels
                 * 0 = Off
                 * 1-4 are equal to the amount of flashlight level steps enabled from the control center module
                 */
                if(([[NSClassFromString(@"SBUIFlashlightController") sharedInstance] level] > 0)) {
                    if(settingsValueFor(@"RequestsFlastlightExcemption")) return;
                }

                /*
                 * If there is any content we likely want to check it out.
                 */
                if(self.mainPageContentViewController.combinedListViewController.hasContent) {
                    /*
                     * Access the notification list view controller
                     */
                    NCNotificationListViewController *listController = [self.mainPageContentViewController.combinedListViewController valueForKey:@"_listViewController"];

                    if([listController hasVisibleContent]) {
                        /*
                        * If notifications are showing and user requests disabling for them, stop here
                        */
                        if(settingsValueFor(@"RequestsContentExcemption")) return;
                    }

                    if(self.isShowingMediaControls) {
                        /*
                        * If media controls are showing and user requests disabling for them, stop here
                        */
                        if(settingsValueFor(@"RequestsMediaExcemption")) return;
                    }

                }
                /*
                 * We're authenticated and have no reason to disable unlocking, send unlock request
                 */
                [[NSClassFromString(@"SBLockScreenManager") sharedInstance] lockScreenViewControllerRequestsUnlock];
            }
        }
    }
}

- (void)setInScreenOffMode:(BOOL)screenOff {

    %orig;

    /*
     * Reset fux_alreadyAuthenticated. If screen goes off we are not authenticated anymore.
     */
     self.fux_alreadyAuthenticated = !screenOff;
}

%end

%hook SBDashBoardPearlUnlockBehavior

-(void)_handlePearlFailure {

    %orig;

    if(settingsValueFor(@"FUXEnabled")) {
        if(settingsValueFor(@"RequestsAutoPearlRetry")) {

            /*
             * If user requests retrying for pearl failure, call noteScreenDidTurnOff on SBUIBiometricResource
             * and then noteScreenWillTurnOn after a short delay to trick it to rescan
             *
             * Thanks to gilshahar7 for sending me this part of code, he also mentioned to credit ipad_kid for his help
             */
            [[NSClassFromString(@"SBUIBiometricResource") sharedInstance] noteScreenDidTurnOff];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSClassFromString(@"SBUIBiometricResource") sharedInstance] noteScreenWillTurnOn];
            });
        }
    }
}
%end

static void setupDefaults () {

    /*
     * If no value exists for the FUXEnabled setting set it as not enabled
     */
    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("FUXEnabled"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"FUXEnabled", (CFPropertyListRef)@0, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    /*
     * Do the same as above just for the other settings. Only change is here I am setting them as enabled by default.
     */

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsAutoPearlRetry"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsAutoPearlRetry", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsFlastlightExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsFlastlightExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsMediaExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsMediaExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsContentExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsContentExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

}

%ctor {
    setupDefaults();
}
