//
//  Utility.h
//  ImageShowcase
//
//  Created by Mirza Bilal on 12/26/12.
//  Copyright (c) 2012 Mirza Bilal. All rights reserved.
//

#ifndef ImageShowcase_Utility_h
#define ImageShowcase_Utility_h

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#endif
