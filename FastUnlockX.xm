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
	self.fux_alreadyAuthenticated = self.authenticated;
}

- (void)setAuthenticated:(BOOL)authenticated {
	%orig;
	if(authenticated) {
		if(!self.fux_alreadyAuthenticated) {
			if(!self.mainPageContentViewController.combinedListViewController.hasContent) {
				[[NSClassFromString(@"SBLockScreenManager") sharedInstance] lockScreenViewControllerRequestsUnlock];
			}
		}
	}
}

- (void)setInScreenOffMode:(BOOL)screenOff {
	%orig;
	self.fux_alreadyAuthenticated = !screenOff;
}

%end
