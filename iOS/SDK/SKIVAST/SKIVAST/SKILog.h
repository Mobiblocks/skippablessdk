//
//  SKILog.h
//  SKIPPABLES
//
//  Created by Daniel on 10/10/17.
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKILog_h
#define SKILog_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#ifdef DEBUG
#   define DVLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DVLog(...)
#endif

#ifdef DEBUG
#   define SDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define SDLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#endif

#endif /* SKILog_h */
