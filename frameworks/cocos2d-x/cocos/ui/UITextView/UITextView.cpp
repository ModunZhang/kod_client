//
//  UITextView.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#include "UITextView.h"
#include "UITextViewImpl.h"

NS_CC_BEGIN

static const float CHECK_TEXTVIEW_POSITION_INTERVAL = 0.1f;

namespace ui {

UITextView::UITextView(void)
:_textViewImpl(nullptr)
, _delegate(nullptr)
, _textViewInputMode(EditBox::InputMode::ANY)
, _textViewInputFlag(EditBox::InputFlag::INTIAL_CAPS_ALL_CHARACTERS)
, _keyboardReturnType(EditBox::KeyboardReturnType::DEFAULT)
, _fontSize(-1)
, _placeholderFontSize(-1)
, _colText(Color3B::WHITE)
, _colPlaceHolder(Color3B::GRAY)
, _maxLength(0)
, _adjustHeight(0.0f)
, _backgroundSprite(nullptr)
,_rectTrackedNode(nullptr)
#if CC_ENABLE_SCRIPT_BINDING
, _scriptEditBoxHandler(0)
#endif
{
}

UITextView::~UITextView()
{
    CC_SAFE_DELETE(_textViewImpl);
#if CC_ENABLE_SCRIPT_BINDING
    unregisterScriptTextViewHandler();
#endif
}

void UITextView::touchDownAction(Ref *sender,TouchEventType controlEvent)
{
    if (controlEvent == Widget::TouchEventType::ENDED) {
        _textViewImpl->openKeyboard();
    }
}

UITextView* UITextView::create(const Size& size,const std::string& normalSprite,TextureResType texType)
{
    UITextView* pRet = new UITextView();
    
    if (pRet != nullptr && pRet->initWithSizeAndBackgroundSprite(size, normalSprite, texType))
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    
    return pRet;
}

UITextView* UITextView::create(const Size& size,Scale9Sprite* normalSprite,Scale9Sprite* pressedSprite, Scale9Sprite* disabledSprite)
{
    UITextView* pRet = new (std::nothrow) UITextView();
    
    if (pRet != nullptr && pRet->initWithSizeAndBackgroundSprite(size, normalSprite))
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    
    return pRet;
}

bool UITextView::initWithSizeAndBackgroundSprite(const cocos2d::Size &size, cocos2d::ui::Scale9Sprite *pNormal9SpriteBg)
{
    if (Widget::init())
    {
        _textViewImpl = __createSystemTextView(this);
        _textViewImpl->initWithSize(size);
        _textViewImpl->setInputMode(EditBox::InputMode::ANY);
        
        _backgroundSprite = pNormal9SpriteBg;
        
        this->setContentSize(size);
        this->setPosition(Vec2(0, 0));
        
        _backgroundSprite->setPosition(Vec2(_contentSize.width/2, _contentSize.height/2));
        _backgroundSprite->setContentSize(size);
        this->addProtectedChild(_backgroundSprite);
        
        this->setTouchEnabled(true);
        
        this->addTouchEventListener(CC_CALLBACK_2(UITextView::touchDownAction, this));
        
        return true;
    }
    return false;
}
    
bool UITextView::initWithSizeAndBackgroundSprite(const cocos2d::Size &size, const std::string &pNormal9SpriteBg,TextureResType texType)
{
    if (Widget::init())
    {
        _textViewImpl = __createSystemTextView(this);
        _textViewImpl->initWithSize(size);
        _textViewImpl->setInputMode(EditBox::InputMode::ANY);
        
        if (texType == Widget::TextureResType::LOCAL)
        {
            _backgroundSprite = Scale9Sprite::create(pNormal9SpriteBg);
        }
        else
        {
            _backgroundSprite = Scale9Sprite::createWithSpriteFrameName(pNormal9SpriteBg);
        }
        this->setContentSize(size);
        this->setPosition(Vec2(0, 0));
        
        _backgroundSprite->setPosition(Vec2(_contentSize.width/2, _contentSize.height/2));
        _backgroundSprite->setContentSize(size);
        this->addProtectedChild(_backgroundSprite);
        
        this->setTouchEnabled(true);
        
        this->addTouchEventListener(CC_CALLBACK_2(UITextView::touchDownAction, this));
        
        return true;
    }
    return false;
}
    
void UITextView::setDelegate(cocos2d::ui::UITextViewDelegate *pDelegate)
{
    _delegate = pDelegate;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setDelegate(pDelegate);
    }
}
void UITextView::setText(const char* pText)
{
    if (pText != nullptr)
    {
        _text = pText;
        if (_textViewImpl != nullptr)
        {
            _textViewImpl->setText(pText);
        }
    }
}

const char* UITextView::getText(void)
{
    if (_textViewImpl != nullptr)
    {
        const char* pText = _textViewImpl->getText();
        if(pText != nullptr)
            return pText;
    }
    
    return "";
}

void UITextView::setFont(const char* pFontName, int fontSize)
{
    _fontName = pFontName;
    _fontSize = fontSize;
    if (pFontName != nullptr)
    {
        if (_textViewImpl != nullptr)
        {
            _textViewImpl->setFont(pFontName, fontSize);
        }
    }
}

void UITextView::setFontName(const char* pFontName)
{
    _fontName = pFontName;
    if (_textViewImpl != nullptr && _fontSize != -1)
    {
        _textViewImpl->setFont(pFontName, _fontSize);
    }
}

void UITextView::setFontSize(int fontSize)
{
    _fontSize = fontSize;
    if (_textViewImpl != nullptr && _fontName.length() > 0)
    {
        _textViewImpl->setFont(_fontName.c_str(), _fontSize);
    }
}

void UITextView::setFontColor(const Color3B& color)
{
    _colText = color;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setFontColor(color);
    }
}

void UITextView::setPlaceholderFont(const char* pFontName, int fontSize)
{
    _placeholderFontName = pFontName;
    _placeholderFontSize = fontSize;
    if (pFontName != nullptr)
    {
        if (_textViewImpl != nullptr)
        {
            _textViewImpl->setPlaceholderFont(pFontName, fontSize);
        }
    }
}

void UITextView::setPlaceholderFontName(const char* pFontName)
{
    _placeholderFontName = pFontName;
    if (_textViewImpl != nullptr && _placeholderFontSize != -1)
    {
        _textViewImpl->setPlaceholderFont(pFontName, _fontSize);
    }
}

void UITextView::setPlaceholderFontSize(int fontSize)
{
    _placeholderFontSize = fontSize;
    if (_textViewImpl != nullptr && _placeholderFontName.length() > 0)
    {
        _textViewImpl->setPlaceholderFont(_placeholderFontName.c_str(), fontSize);
    }
}

void UITextView::setPlaceholderFontColor(const Color3B& color)
{
    _colText = color;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setPlaceholderFontColor(color);
    }
}

void UITextView::setPlaceHolder(const char* pText)
{
    if (pText != nullptr)
    {
        _placeHolder = pText;
        if (_textViewImpl != nullptr)
        {
            _textViewImpl->setPlaceHolder(pText);
        }
    }
}

const char* UITextView::getPlaceHolder(void)
{
    return _placeHolder.c_str();
}

void UITextView::setInputMode(EditBox::InputMode inputMode)
{
    _textViewInputMode = inputMode;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setInputMode(inputMode);
    }
}

void UITextView::setMaxLength(int maxLength)
{
    _maxLength = maxLength;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setMaxLength(maxLength);
    }
}


int UITextView::getMaxLength()
{
    return _maxLength;
}

void UITextView::setInputFlag(EditBox::InputFlag inputFlag)
{
    _textViewInputFlag = inputFlag;
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setInputFlag(inputFlag);
    }
}

void UITextView::setReturnType(EditBox::KeyboardReturnType returnType)
{
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setReturnType(returnType);
    }
}

/* override function */
void UITextView::setPosition(const Vec2& pos)
{
    Widget::setPosition(pos);
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setPosition(pos);
    }
}

void UITextView::setVisible(bool visible)
{
    Widget::setVisible(visible);
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setVisible(visible);
    }
}

void UITextView::setContentSize(const Size& size)
{
    Widget::setContentSize(size);
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setContentSize(size);
    }
}

void UITextView::adaptRenderers()
{
    if (_contentSizeDirty)
    {
        _backgroundSprite->setContentSize(_contentSize);
        _backgroundSprite->setPosition(Vec2(_contentSize.width/2, _contentSize.height/2));
    }
}

void UITextView::setAnchorPoint(const Vec2& anchorPoint)
{
    Widget::setAnchorPoint(anchorPoint);
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->setAnchorPoint(anchorPoint);
    }
}

void UITextView::visit(Renderer *renderer, const Mat4 &parentTransform, uint32_t parentFlags)
{
    Widget::visit(renderer, parentTransform, parentFlags);
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->visit();
    }
}

void UITextView::onEnter(void)
{
#if CC_ENABLE_SCRIPT_BINDING
    if (_scriptType == kScriptTypeJavascript)
    {
        if (ScriptEngineManager::sendNodeEventToJSExtended(this, kNodeOnEnter))
            return;
    }
#endif
    
    Widget::onEnter();
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->onEnter();
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    this->schedule(CC_SCHEDULE_SELECTOR(UITextView::updatePosition), CHECK_TEXTVIEW_POSITION_INTERVAL);
#endif
}

void UITextView::updatePosition(float dt)
{
    if (nullptr != _textViewImpl) {
        _textViewImpl->updatePosition(dt);
    }
}


void UITextView::onExit(void)
{
    Widget::onExit();
    if (_textViewImpl != nullptr)
    {
        // remove system edit control
        _textViewImpl->closeKeyboard();
    }
}

static Rect getRect(Node * pNode)
{
    Size contentSize = pNode->getContentSize();
    Rect rect = Rect(0, 0, contentSize.width, contentSize.height);
    return RectApplyTransform(rect, pNode->getNodeToWorldTransform());
}

void UITextView::keyboardWillShow(IMEKeyboardNotificationInfo& info)
{
    // CCLOG("CCEditBox::keyboardWillShow");
    Rect rectTracked = getRect(this);
    // some adjustment for margin between the keyboard and the edit box.
    rectTracked.origin.y -= 4;
    
    // if the keyboard area doesn't intersect with the tracking node area, nothing needs to be done.
    if (!rectTracked.intersectsRect(info.end))
    {
        CCLOG("needn't to adjust view layout.");
        return;
    }
    
    // assume keyboard at the bottom of screen, calculate the vertical adjustment.
    _adjustHeight = info.end.getMaxY() - rectTracked.getMinY();
    // CCLOG("CCEditBox:needAdjustVerticalPosition(%f)", _adjustHeight);
    
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->doAnimationWhenKeyboardMove(info.duration, _adjustHeight);
    }
}

void UITextView::keyboardDidShow(IMEKeyboardNotificationInfo& info)
{
    
}

void UITextView::keyboardWillHide(IMEKeyboardNotificationInfo& info)
{
    // CCLOG("CCEditBox::keyboardWillHide");
    if (_textViewImpl != nullptr)
    {
        _textViewImpl->doAnimationWhenKeyboardMove(info.duration, -_adjustHeight);
    }
}

void UITextView::keyboardDidHide(IMEKeyboardNotificationInfo& info)
{
    
}

#if CC_ENABLE_SCRIPT_BINDING
void UITextView::registerScriptTextViewHandler(int handler)
{
    unregisterScriptTextViewHandler();
    _scriptEditBoxHandler = handler;
}

void UITextView::unregisterScriptTextViewHandler(void)
{
    if (0 != _scriptEditBoxHandler)
    {
        ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_scriptEditBoxHandler);
        _scriptEditBoxHandler = 0;
    }
}
#endif

void UITextView::closeKeyboard()
{
    _textViewImpl->closeKeyboard();
}
}
NS_CC_END