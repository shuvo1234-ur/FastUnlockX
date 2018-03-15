//
//  FastUnlockX.xm
//  FastUnlockX
//
//  Created by Juan Carlos Perez on 01/19/2018.
//  Copyright © 2017 CP Digital Darkroom. All rights reserved.
//

#import "FastUnlockX.h"

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

- (void)setAuthenticated:(BOOL)authenticated {

    %orig;

    if(authenticated) {

        if([(id)CFPreferencesCopyAppValue(CFSTR("FUXEnabled"), CFSTR("com.cpdigitaldarkroom.fastunlockx")) boolValue]) {

            /*
             * If already authenticated we manually invoked the cover sheet and want to be there. Don't unlock.
             */
            if(!self.fux_alreadyAuthenticated) {

                /*
                 * If there is any content we likely want to check it out.
                 */
                BOOL haveContent = self.mainPageContentViewController.combinedListViewController.hasContent;

                /*
                 * Flashlight Levels
                 * 0 = Off
                 * 1-4 are equal to the amount of flashlight level steps enabled from the control center module
                 */
                BOOL flashlightOn = ([[NSClassFromString(@"SBUIFlashlightController") sharedInstance] level] > 0);

                BOOL requestsFlashlightExcemption = [(id)CFPreferencesCopyAppValue(CFSTR("RequestsFlastlightExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")) boolValue];
                BOOL requestsContentExcemption = [(id)CFPreferencesCopyAppValue(CFSTR("RequestsContentExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")) boolValue];

                if(flashlightOn && requestsFlashlightExcemption) return;

                if((haveContent &! requestsContentExcemption) || !haveContent) {
                    [[NSClassFromString(@"SBLockScreenManager") sharedInstance] lockScreenViewControllerRequestsUnlock];
                }
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

static void setupDefaults () {

    /*
     * If no value exists for the FUXEnabled setting set it as not enabled
     */
    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("FUXEnabled"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"FUXEnabled", (CFPropertyListRef)@0, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    /*
     * Do the same as above just for the other settings
     */
    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsFlastlightExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsFlastlightExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsMediaExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsMediaExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

    if(!CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("RequestsNotificationExcemption"), CFSTR("com.cpdigitaldarkroom.fastunlockx")))) {
        CFPreferencesSetAppValue((CFStringRef)@"RequestsNotificationExcemption", (CFPropertyListRef)@1, CFSTR("com.cpdigitaldarkroom.fastunlockx"));
    }

}

%ctor {

    setupDefaults();
}
