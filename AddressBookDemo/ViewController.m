//
//  ViewController.m
//  AddressBookDemo
//
//  Created by BlueSea on 2018/1/12.
//  Copyright © 2018年 山茶花酿酒. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface ViewController ()
<CNContactPickerDelegate,
ABPeoplePickerNavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self checkAddressBookAuthorizationCompletionHandler:^(BOOL granted) {
        NSLog(@"%d", granted);
        
        if (granted==YES) {
            [self setupAddressBookUI];
        }
        
    }];
    
}

/** 检查通讯录权限 */
- (void)checkAddressBookAuthorizationCompletionHandler:(void (^)(BOOL granted))completionHandler {
    
    if (@available(iOS 9.0, *)) {
        
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status==CNAuthorizationStatusNotDetermined) {
            
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                completionHandler(granted);
            }];
            
        } else if (status==CNAuthorizationStatusAuthorized) {
            completionHandler(YES);
        } else {
            completionHandler(NO);
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    } else {
        
        // Fallback on earlier versions
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status==kABAuthorizationStatusNotDetermined) {
            
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(granted);
                });
            });
            
        } else if (status==kABAuthorizationStatusAuthorized) {
            completionHandler(YES);
        } else {
            completionHandler(NO);
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    }
}

- (void)setupAddressBookUI {
    
    if (@available(iOS 9.0, *)) {
        
        CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
        contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//用户详情信息显示
        contactPicker.delegate = self;
        [self presentViewController:contactPicker animated:YES completion:nil];
        
    } else {
        
        ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
        peoplePicker.peoplePickerDelegate = self;
        [self presentViewController:peoplePicker animated:YES completion:nil];
    }
}

#pragma mark -- CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *name = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName, contactProperty.contact.givenName];
        NSString *phone = phoneNumber.stringValue;
        NSLog(@"联系人：%@, 电话：%@", name, phone);
    }];
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *name = [NSString stringWithFormat:@"%@", anFullName];
        NSString *phone = (__bridge NSString*)value;
        NSLog(@"联系人：%@, 电话：%@", name, phone);
    }];
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
