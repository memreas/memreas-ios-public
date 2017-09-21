#import <Foundation/Foundation.h>
#import "asl.h"

#ifndef MW_COMPILE_TIME_LOG_LEVEL
#ifdef NDEBUG
#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_NOTICE
#else
#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif
#endif

/*
ASL_LEVEL_EMERG
 The highest priority, usually reserved for catastrophic failures and reboot notices.
ASL_LEVEL_ALERT
 A serious failure in a key system.
ASL_LEVEL_CRIT
 A failure in a key system.
ASL_LEVEL_ERR
 Something has failed.
ASL_LEVEL_WARNING
 Something is amiss and might fail if not corrected.
ASL_LEVEL_NOTICE
 Things of moderate interest to the user or administrator.
ASL_LEVEL_INFO
 The lowest priority that you would normally log, and purely informational in nature.
ASL_LEVEL_DEBUG
 The lowest priority, and normally not logged except for messages from the kernel.
*/
 
#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
    #ifdef DEBUG
            #define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
        #else
            #define NSLog(x...)
    #endif
#endif

void MNSLog(NSString* level, const char *file, int lineNumber, const char *functionName, NSString *format, ...);
