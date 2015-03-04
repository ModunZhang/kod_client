//
//  UITextViewImpl-ios.h
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#ifndef __UITextViewImpl_ios__
#define __UITextViewImpl_ios__

#include "platform/CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include "extensions/ExtensionMacros.h"
#include "UITextViewImpl.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCCustomUITextView : UITextView
{
}
@end


@interface CCTextViewImplIOS_objc : NSObject <UITextViewDelegate>
{
    CCCustomUITextView* textView_;
    void* dtextView_;
    BOOL editState_;
}

@property(nonatomic, retain) UITextView* textView;
@property(nonatomic, readonly, getter = isEditState) BOOL editState;
@property(nonatomic, assign) void* dtextView;

-(id) initWithFrame: (CGRect) frameRect textView: (void*) dtextView;
-(void) doAnimationWhenKeyboardMoveWithDuration:(float)duration distance:(float)distance;
-(void) setPosition:(CGPoint) pos;
-(void) setContentSize:(CGSize) size;
-(void) visit;
-(void) openKeyboard;
-(void) closeKeyboard;
@end

NS_CC_BEGIN

namespace ui {
    
class UITextView;
class UITextViewImplIOS : public UITextViewImpl
{
public:
    
    UITextViewImplIOS(UITextView* textView);
    virtual ~UITextViewImplIOS();
    virtual bool initWithSize(const Size& size);
    virtual void setFont(const char* pFontName, int fontSize);
    virtual void setFontColor(const Color3B& color);
    virtual void setPlaceholderFont(const char* pFontName, int fontSize);
    virtual void setPlaceholderFontColor(const Color3B& color);
    virtual void setInputMode(EditBox::InputMode inputMode);
    virtual void setInputFlag(EditBox::InputFlag inputFlag);
    virtual void setMaxLength(int maxLength);
    virtual int  getMaxLength();
    virtual void setReturnType(EditBox::KeyboardReturnType returnType);
    virtual bool isEditing();
    virtual void setEnable(bool enable);
    virtual void setText(const char* pText);
    virtual const char* getText(void);
    virtual void refreshInactiveText();
    virtual void setPlaceHolder(const char* pText);
    virtual void setPosition(const Vec2& pos);
    virtual void setVisible(bool visible);
    virtual void setContentSize(const Size& size);
    virtual void setAnchorPoint(const Vec2& anchorPoint);
    virtual void updatePosition(float dt) override;
    /**
     * @js NA
     * @lua NA
     */
    virtual void visit(void);
    /**
     * @js NA
     * @lua NA
     */
    virtual void onEnter(void);
    virtual void doAnimationWhenKeyboardMove(float duration, float distance);
    virtual void openKeyboard();
    virtual void closeKeyboard();
    
    virtual void onEndEditing();
private:
    void			initInactiveLabels(const Size& size);
    void			setInactiveText(const char* pText);
    void			adjustTextFieldPosition();
    void            placeInactiveLabels();
    
    Label*     _label;
    Label*     _labelPlaceHolder;
    Size          _contentSize;
    Vec2         _position;
    Vec2         _anchorPoint;
    CCTextViewImplIOS_objc* _systemControl;
    int             _maxTextLength;
    bool            _inRetinaMode;
};
    
}
NS_CC_END
#endif/* #if (..) */
#endif
