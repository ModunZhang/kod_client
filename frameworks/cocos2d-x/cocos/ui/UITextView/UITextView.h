//
//  UITextView.h
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#ifndef __cocos2d_libs__UITextView__
#define __cocos2d_libs__UITextView__

#include "base/CCIMEDelegate.h"
#include "ui/GUIDefine.h"
#include "ui/UIButton.h"
#include "ui/UIScale9Sprite.h"
#include "../UIEditBox/UIEditBox.h"

NS_CC_BEGIN

namespace ui {
    
    class UITextView;
    class UITextViewImpl;
    
    class UITextViewDelegate
    {
    public:
        virtual ~UITextViewDelegate() {};
        
        virtual void textViewDidBeginEditing(UITextView* textView){};
        
        virtual void textViewTextChanged(UITextView* textView,const std::string& text){};
        
        virtual void textViewDidEndEditing(UITextView* textView) = 0;
    };
    
    
    class UITextView
    :public Widget
    ,public IMEDelegate
    {
    public:
        UITextView(void);
        
        virtual ~UITextView();
        
        static UITextView* create(const Size& size,Scale9Sprite* pNormal9SpriteBg,
                                  Scale9Sprite* pPressed9SpriteBg = nullptr, Scale9Sprite* pDisabled9SpriteBg = nullptr);
        
        static UITextView* create(const Size& size,
                               const std::string& pNormal9SpriteBg,
                               TextureResType texType = TextureResType::LOCAL);
        
        bool initWithSizeAndBackgroundSprite(const Size& size,
                                             const std::string& pNormal9SpriteBg,
                                             TextureResType texType = TextureResType::LOCAL);
        
        bool initWithSizeAndBackgroundSprite(const Size& size, Scale9Sprite* pNormal9SpriteBg);
        
        void setDelegate(UITextViewDelegate* pDelegate);
        
        UITextViewDelegate* getDelegate(){ return _delegate;};
        
        void setRectTrackedNode(Node * node){
            _rectTrackedNode = node;
        };
        
        Node * getRectTrackedNode(){
            return _rectTrackedNode;
        };
#if CC_ENABLE_SCRIPT_BINDING
        void registerScriptTextViewHandler(int handler);
        
        /**
         * Unregisters a script function that will be called for EditBox events.
         * @js NA
         * @lua NA
         */
        void unregisterScriptTextViewHandler(void);
        /**
         * get a script Handler
         * @js NA
         * @lua NA
         */
        int  getScriptTextViewHandler(void){ return _scriptEditBoxHandler ;}
        
#endif // #if CC_ENABLE_SCRIPT_BINDING
        void setText(const char* pText);
        
        void setEnable(bool enable);
        
        const char* getText(void);
        
        void setFont(const char* pFontName, int fontSize);
        
        /**
         * Set the font name.
         * @param pFontName The font name.
         */
        void setFontName(const char* pFontName);
        
        /**
         * Set the font size.
         * @param fontSize The font size.
         */
        void setFontSize(int fontSize);
        
        /**
         * Set the font color of the widget's text.
         */
        void setFontColor(const Color3B& color);
        
        /**
         * Set the placeholder's font.
         * @param pFontName The font name.
         * @param fontSize The font size.
         */
        void setPlaceholderFont(const char* pFontName, int fontSize);
        
        /**
         * Set the placeholder's font name.
         * @param pFontName The font name.
         */
        void setPlaceholderFontName(const char* pFontName);
        
        /**
         * Set the placeholder's font size.
         * @param fontSize The font size.
         */
        void setPlaceholderFontSize(int fontSize);
        
        /**
         * Set the font color of the placeholder text when the edit box is empty.
         * Not supported on IOS.
         */
        void setPlaceholderFontColor(const Color3B& color);
        
        /**
         * Set a text in the edit box that acts as a placeholder when an
         * edit box is empty.
         * @param pText The given text.
         */
        void setPlaceHolder(const char* pText);
        
        /**
         * Get a text in the edit box that acts as a placeholder when an
         * edit box is empty.
         */
        const char* getPlaceHolder(void);
        
        /**
         * Set the input mode of the edit box.
         * @param inputMode One of the EditBox::InputMode constants.
         */
        void setInputMode(EditBox::InputMode inputMode);
        
        /**
         * Sets the maximum input length of the edit box.
         * Setting this value enables multiline input mode by default.
         * Available on Android, iOS and Windows Phone.
         *
         * @param maxLength The maximum length.
         */
        void setMaxLength(int maxLength);
        
        /**
         * Gets the maximum input length of the edit box.
         *
         * @return Maximum input length.
         */
        int getMaxLength();
        
        /**
         * Set the input flags that are to be applied to the edit box.
         * @param inputFlag One of the EditBox::InputFlag constants.
         */
        void setInputFlag(EditBox::InputFlag inputFlag);
        
        /**
         * Set the return type that are to be applied to the edit box.
         * @param returnType One of the EditBox::KeyboardReturnType constants.
         */
        void setReturnType(EditBox::KeyboardReturnType returnType);
        
        
        /* override functions */
        virtual void setPosition(const Vec2& pos) override;
        virtual void setVisible(bool visible) override;
        virtual void setContentSize(const Size& size) override;
        virtual void setAnchorPoint(const Vec2& anchorPoint) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void visit(Renderer *renderer, const Mat4 &parentTransform, uint32_t parentFlags) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onEnter(void) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void onExit(void) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardWillShow(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardDidShow(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardWillHide(IMEKeyboardNotificationInfo& info) override;
        /**
         * @js NA
         * @lua NA
         */
        virtual void keyboardDidHide(IMEKeyboardNotificationInfo& info) override;
        
        virtual void closeKeyboard();
        /* callback funtions
         * @js NA
         * @lua NA
         */
        void touchDownAction(Ref *sender, TouchEventType controlEvent);
        
        
    protected:
        virtual void adaptRenderers();
        
        void updatePosition(float dt);
        
        UITextViewImpl* _textViewImpl;
        
        UITextViewDelegate* _delegate;
        
        Node *_rectTrackedNode;
        
        EditBox::InputMode    _textViewInputMode;
        EditBox::InputFlag    _textViewInputFlag;
        EditBox::KeyboardReturnType  _keyboardReturnType;
        
        Scale9Sprite *_backgroundSprite;
        std::string _text;
        std::string _placeHolder;
        
        std::string _fontName;
        std::string _placeholderFontName;
        
        int _fontSize;
        int _placeholderFontSize;
        
        Color3B _colText;
        Color3B _colPlaceHolder;
        
        int   _maxLength;
        float _adjustHeight;
#if CC_ENABLE_SCRIPT_BINDING
        int   _scriptEditBoxHandler;
#endif
    };
}

NS_CC_END
#endif /* defined(__cocos2d_libs__UITextView__) */
