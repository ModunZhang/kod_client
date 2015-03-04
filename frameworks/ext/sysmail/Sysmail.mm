//
//  Sysmail.m
//  kod
//
//  Created by DannyHe on 1/5/15.
//
//

#import "Sysmail.h"
#import <Foundation/Foundation.h>
#import <messageUI/messageUI.h>
@interface sysmail : NSObject <MFMailComposeViewControllerDelegate>
@property(assign,nonatomic)int lua_function_ref;
@property(retain,nonatomic)MFMailComposeViewController *mailCompose;
-(BOOL)sendMail:(NSString *)to
        subject:(NSString*)subject
           body:(NSString*)body;
-(instancetype)initWithLuaFunctionRef:(int)ref_id;
@end

@implementation MFMailComposeViewController (rotate)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
@end

@implementation sysmail
@synthesize lua_function_ref;
@synthesize mailCompose;
-(instancetype)initWithLuaFunctionRef:(int)ref_id
{
    self = [super init];
    if (self)
    {
        self.lua_function_ref = ref_id;
    }
    return self;
}

-(BOOL)sendMail:(NSString *)to
        subject:(NSString *)subject
           body:(NSString *)body
{
    if(!CanSenMail())
    {
        NSLog(@"can not send mail");
        return NO;
    }
    else
    {
        MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
        self.mailCompose = mailPicker;
        [mailPicker release];
        [mailPicker setMailComposeDelegate:self];
        [mailPicker setToRecipients:[NSArray arrayWithObject:to]];
        [mailPicker setSubject:subject];
        [mailPicker setMessageBody:body isHTML:NO];
        [[[[UIApplication sharedApplication]keyWindow] rootViewController]presentModalViewController:mailPicker animated:YES];
    }
    return YES;
}

extern void OnSendMailEnd(int function_id,const char *event);

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    if (self.lua_function_ref > 0)
    {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                OnSendMailEnd(self.lua_function_ref,"Canceled");
                break;
            case MFMailComposeResultSaved:
                OnSendMailEnd(self.lua_function_ref,"Saved");
                break;
            case MFMailComposeResultSent:
                OnSendMailEnd(self.lua_function_ref,"Sent");
                break;
            case MFMailComposeResultFailed:
                OnSendMailEnd(self.lua_function_ref,"Failed");
                break;
            default:
                break;
        }
    }
    [controller dismissModalViewControllerAnimated:YES];
    self.mailCompose = nil;
}
@end

static sysmail* g_instance_mail = NULL;

bool SendMail(const char* to,const char* subject,const char* body,int lua_function_ref)
{
    if (g_instance_mail == NULL) {
        g_instance_mail = [[sysmail alloc]initWithLuaFunctionRef:lua_function_ref];
        return [g_instance_mail sendMail:[NSString stringWithUTF8String:to]
                                 subject:[NSString stringWithUTF8String:subject]
                                    body:[NSString stringWithUTF8String:body]];
    }
    else
    {
        g_instance_mail.lua_function_ref = lua_function_ref;
        return [g_instance_mail sendMail:[NSString stringWithUTF8String:to]
                                 subject:[NSString stringWithUTF8String:subject]
                                    body:[NSString stringWithUTF8String:body]];
    }
}

bool CanSenMail(){
    return [MFMailComposeViewController canSendMail];
}