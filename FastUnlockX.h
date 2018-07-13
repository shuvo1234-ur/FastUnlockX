//
//  FastUnlockX.h
//  FastUnlockX
//
//  Created by Juan Carlos Perez on 01/19/2018.
//  Copyright © 2017 CP Digital Darkroom. All rights reserved.
//

@interface NCNotificationListViewController : UICollectionViewController
-(BOOL)hasVisibleContent;
@end

@interface NCNotificationCombinedListViewController : NCNotificationListViewController
@end

@interface SBUIBiometricResource : NSObject
+ (id)sharedInstance;
- (void)noteScreenDidTurnOff;
- (void)noteScreenWillTurnOn;
@end

@interface SBDashBoardViewControllerBase : UIViewController
@end

@interface SBDashBoardPresentationViewController : SBDashBoardViewControllerBase
@end

@interface SBDashBoardPageViewController : SBDashBoardPresentationViewController
@end

@interface SBDashBoardCombinedListViewController : SBDashBoardViewControllerBase {
	NCNotificationCombinedListViewController *_listViewController;
}
@property (nonatomic,retain) NSMutableOrderedSet * filteredNotificationRequests;
@property(readonly, nonatomic) BOOL hasContent;
@end

@interface SBDashBoardMainPageContentViewController : SBDashBoardPageViewController
@property(readonly, nonatomic) SBDashBoardCombinedListViewController *combinedListViewController;
@end

@interface SBDashBoardPearlUnlockBehavior : NSObject
-(void)mesaUnlockTriggerFired:(id)arg1 ;
@end

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBDashBoardViewController : SBLockScreenViewControllerBase
@property(assign, nonatomic) BOOL fux_alreadyAuthenticated;
@property(nonatomic, getter=isAuthenticated) BOOL authenticated;
@property(retain, nonatomic) SBDashBoardMainPageContentViewController *mainPageContentViewController;
- (BOOL)isShowingMediaControls;
- (BOOL)isInScreenOffMode;
- (BOOL)biometricUnlockBehavior:(id)arg1 requestsUnlock:(id)arg2 withFeedback:(id)arg3 ;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)tapToWakeControllerDidRecognizeWakeGesture:(id)arg1;
- (void)lockScreenViewControllerRequestsUnlock;
@end

@interface SBUIFlashlightController : NSObject

+(id)sharedInstance;

-(NSInteger)level;

@end

