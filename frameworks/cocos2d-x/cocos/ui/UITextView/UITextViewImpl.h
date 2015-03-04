//
//  UITextViewImpl.h
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#ifndef __UITextViewImpl___
#define __UITextViewImpl___

#include "UITextView.h"

NS_CC_BEGIN

namespace ui {
    class CC_GUI_DLL UITextViewImpl
    {
    public:
        UITextViewImpl(UITextView *pTextView) : _delegate(NULL),_textView(pTextView){}
        virtual ~UITextViewImpl(){}
        virtual bool initWithSize(const Size& size) = 0;
        virtual void setFont(const char* pFontName, int fontSize) = 0;
        virtual void setFontColor(const Color3B& color) = 0;
        virtual void setPlaceholderFont(const char* pFontName, int fontSize) = 0;
        virtual void setPlaceholderFontColor(const Color3B& color) = 0;
        virtual void setInputMode(EditBox::InputMode inputMode) = 0;
        virtual void setInputFlag(EditBox::InputFlag inputFlag) = 0;
        virtual void setMaxLength(int maxLength) = 0;
        virtual int  getMaxLength() = 0;
        virtual void setReturnType(EditBox::KeyboardReturnType returnType) = 0;
        virtual bool isEditing() = 0;
        virtual void setEnable(bool enable) = 0;
        virtual void setText(const char* pText) = 0;
        virtual const char* getText(void) = 0;
        virtual void setPlaceHolder(const char* pText) = 0;
        virtual void doAnimationWhenKeyboardMove(float duration, float distance) = 0;
        
        virtual void openKeyboard() = 0;
        virtual void closeKeyboard() = 0;
        
        virtual void setPosition(const Vec2& pos) = 0;
        virtual void setVisible(bool visible) = 0;
        virtual void setContentSize(const Size& size) = 0;
        virtual void setAnchorPoint(const Vec2& anchorPoint) = 0;
        
        /**
         * check the editbox's position, update it when needed
         */
        virtual void updatePosition(float dt){};
        /**
         * @js NA
         * @lua NA
         */
        virtual void visit(void) = 0;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onEnter(void) = 0;
        
        
        void setDelegate(UITextViewDelegate* pDelegate) {
            _delegate = pDelegate;
        };
        UITextViewDelegate* getDelegate() { return _delegate; };
        UITextView* getTextView() { return _textView; };
    protected:
        UITextView* _textView;
        UITextViewDelegate* _delegate;
    };
    // This method must be implemented at each subclass of EditBoxImpl.
    extern UITextViewImpl* __createSystemTextView(UITextView* pTextView);
}

NS_CC_END

#endif
