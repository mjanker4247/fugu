/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

#import <Foundation/Foundation.h>

// Modern file notification methods
int notifyFileModified(NSString *path, NSString *senderToken);
void notifyFileSaved(NSString *path, NSString *senderToken);
void notifyFileClosed(NSString *path);
