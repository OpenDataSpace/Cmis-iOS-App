//
//  UploadInfo.h
//  ODS
//
//  Created by bdt on 8/27/14.
//  Copyright (c) 2014 Open Data Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISUploadRequest;

typedef enum
{
    UploadInfoStatusInactive,
    UploadInfoStatusActive,
    UploadInfoStatusUploading,
    UploadInfoStatusUploaded,
    UploadInfoStatusFailed
} UploadInfoStatus;

typedef enum
{
    UploadFormTypePhoto,
    UploadFormTypeVideo,
    UploadFormTypeAudio,
    UploadFormTypeDocument,
    UploadFormTypeLibrary,
    UploadFormTypeMultipleDocuments,
    UploadFormTypeCreateDocument
} UploadFormType;

@interface UploadInfo : NSObject

@property (nonatomic, copy) NSString            *uuid;
@property (nonatomic, strong) NSURL             *uploadFileURL;
@property (nonatomic, copy) NSString            *filename;
@property (nonatomic, copy) NSString            *extension;
@property (nonatomic, copy) NSString            *cmisObjectId;

@property (nonatomic, strong) NSDate            *uploadDate;
@property (nonatomic, assign) UploadInfoStatus  uploadStatus;
@property (nonatomic, assign) UploadFormType    uploadType;

@property (nonatomic, retain) NSError           *error;
@property (nonatomic, copy) NSString            *folderName;
@property (nonatomic, copy) NSString            *targetFolderIdentifier;
@property (nonatomic, copy) NSString            *repositoryIdentifier;
@property (nonatomic, copy) NSString            *selectedAccountUUID;
@property (nonatomic, assign) BOOL              uploadFileIsTemporary;

@property (nonatomic, strong) CMISUploadRequest *uploadRequest;

- (NSString *)completeFileName;

- (BOOL) sourceFileExists;

- (float) uploadedProgress;
@end
