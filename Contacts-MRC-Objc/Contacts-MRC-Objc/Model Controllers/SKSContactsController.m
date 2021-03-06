//
//  SKSContactsController.m
//  Contacts-MRC-Objc
//
//  Created by Lambda_School_Loaner_204 on 1/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

#import "SKSContactsController.h"
#import "SKSContact.h"

@interface SKSContactsController()

@end

@implementation SKSContactsController

- (instancetype)init {
    self = [super init];
    if (self) {
        _contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addContact:(SKSContact *)contact {
    [self.contacts addObject:contact];
}

- (void)randomUsersContacts:(NSString *)users completion:(void (^)(NSError *_Nullable))completion {

    NSURL *baseURL = [NSURL URLWithString:@"https://randomuser.me/api/"];
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
    NSURLQueryItem *includeItem = [NSURLQueryItem queryItemWithName:@"inc" value:@"name,email,phone"];
    NSURLQueryItem *resultItem = [NSURLQueryItem queryItemWithName:@"results" value:users];
    components.queryItems = @[includeItem, resultItem];
    NSURL *url = components.URL;

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            NSLog(@"Error: %@", error);
            completion(error);
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            NSLog(@"JsonError: %@", jsonError);
            completion(jsonError);
            return;
        }

        if(![dictionary isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Not of dictionary type");
            NSString *desc = NSLocalizedString(@"Not a dictionary", @"");
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
            NSError *dictionaryError = [NSError errorWithDomain:@"" code:-101 userInfo:userInfo];
            completion(dictionaryError);
            return;
        }

        NSArray *userDictionaries = dictionary[@"results"];
        for (NSDictionary *userDictionary in userDictionaries) {
            SKSContact *contact = [SKSContact contactWithDictionary:userDictionary];
            [self.contacts addObject:contact];
        }
        completion(nil);

    }] resume];

}

- (void)dealloc {
    [_contacts release];
    //_contacts = nil;
    [super dealloc];
}

@end
