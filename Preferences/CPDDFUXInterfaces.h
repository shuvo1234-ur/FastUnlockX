//
//
//    CPDDFUXInterfaces.h
//    Created by Juan Carlos Perez <carlos@jcarlosperez.me> 03/15/2017
//    © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//
//

@interface NSTask : NSObject

- (id)init;
- (void)launch;
- (void)setArguments:(id)arg1;
- (void)setLaunchPath:(id)arg1;
- (void)setStandardOutput:(id)arg1;
- (id)standardOutput;

@end
