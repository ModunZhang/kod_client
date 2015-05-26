//
//  UITextViewImpl-ios.cpp
//  cocos2d_libs
//
//  Created by DannyHe on 3/3/15.
//
//

#include "UITextViewImpl-ios.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include "base/CCDirector.h"
#include "2d/CCLabel.h"
#import "platform/ios/CCEAGLView-ios.h"
#include "UITextView.h"

#define kLabelZOrder  9999
#define gettextViewImplIOS() ((cocos2d::ui::UITextViewImplIOS*)dtextView_)
#define CC_TEXT_VIEW_PADDING 10

//MARK:Objective-C


//maybe not work!!
@implementation CCCustomUITextView

@end


@implementation CCTextViewImplIOS_objc

@synthesize textView = textView_;
@synthesize editState = editState_;
@synthesize dtextView = dtextView_;

-(id) initWithFrame:(CGRect)frameRect textView:(void *)dtextView
{
    self = [super init];
    if (self)
    {
        editState_ = NO;
        self.textView = [[CCCustomUITextView alloc]initWithFrame:frameRect];
        
        [self.textView setTextColor:[UIColor whiteColor]];
        textView_.font = [UIFont systemFontOfSize:10]; //TODO need to delete hard code here.
        //debug frame of textview
#if (COCOS2D_DEBUG>0)
        textView_.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.2];
#else
        textView_.backgroundColor = [UIColor clearColor];
#endif
        textView_.delegate = self;
        textView_.hidden = true;
        [textView_ setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textView_ setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        textView_.returnKeyType = UIReturnKeyDefault;
        self.dtextView = dtextView;
    }
    return self;
}

-(void) doAnimationWhenKeyboardMoveWithDuration:(float)duration distance:(float)distance
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview doAnimationWhenKeyboardMoveWithDuration:duration distance:distance];
}

-(void) setPosition:(CGPoint) pos
{
    CGRect frame = [textView_ frame];
    frame.origin = pos;
    [textView_ setFrame:frame];
}

-(void) setContentSize:(CGSize) size
{
    size.width -= CC_TEXT_VIEW_PADDING;
    size.height -= CC_TEXT_VIEW_PADDING;
    CGRect frame = [textView_ frame];
    frame.size = size;
    [textView_ setFrame:frame];
}

-(void) visit
{
    
}

-(void) openKeyboard
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview addSubview:textView_];
    [textView_ becomeFirstResponder];
}

-(void) closeKeyboard
{
    [textView_ resignFirstResponder];
    [textView_ removeFromSuperview];
}

-(void)animationSelector
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    [eaglview doAnimationWhenAnotherEditBeClicked];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    // CCLOG("textViewShouldBeginEditing...");
    editState_ = YES;
    
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) view->getEAGLView();
    
    if ([eaglview isKeyboardShown])
    {
        [self performSelector:@selector(animationSelector) withObject:nil afterDelay:0.0f];
    }
    cocos2d::ui::UITextViewDelegate *pDelegate = gettextViewImplIOS()->getDelegate();
    if (pDelegate != NULL)
    {
        pDelegate->textViewDidBeginEditing(gettextViewImplIOS()->getTextView());
    }
#if CC_ENABLE_SCRIPT_BINDING
    cocos2d::ui::UITextView*  pTextView= gettextViewImplIOS()->getTextView();
    if (NULL != pTextView && 0 != pTextView->getScriptTextViewHandler())
    {
        cocos2d::CommonScriptData data(pTextView->getScriptTextViewHandler(), "began",pTextView);
        cocos2d::ScriptEvent event(cocos2d::kCommonEvent,(void*)&data);
        cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
    }
#endif
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    // CCLOG("textViewShouldEndEditing...");
    editState_ = NO;
    gettextViewImplIOS()->refreshInactiveText();
    
    cocos2d::ui::UITextViewDelegate* pDelegate = gettextViewImplIOS()->getDelegate();
    if (pDelegate != NULL)
    {
        pDelegate->textViewDidEndEditing(gettextViewImplIOS()->getTextView());
    }
#if CC_ENABLE_SCRIPT_BINDING
    cocos2d::ui::UITextView*  pTextView= gettextViewImplIOS()->getTextView();
    if (NULL != pTextView && 0 != pTextView->getScriptTextViewHandler())
    {
        cocos2d::CommonScriptData data(pTextView->getScriptTextViewHandler(), "ended",pTextView);
        cocos2d::ScriptEvent event(cocos2d::kCommonEvent,(void*)&data);
        cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
        memset(data.eventName, 0, sizeof(data.eventName));
        strncpy(data.eventName, "return", sizeof(data.eventName));
        event.data = (void*)&data;
        cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
    }
#endif
    if (textView_ != nil) {
        gettextViewImplIOS()->onEndEditing();
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (gettextViewImplIOS()->getMaxLength() < 0)
    {
        return YES;
    }
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    return newLength <= gettextViewImplIOS()->getMaxLength();
}

- (void)textViewDidChange:(UITextView *)textView{
    cocos2d::ui::UITextViewDelegate *pDelegate = gettextViewImplIOS()->getDelegate();
    if (NULL!=pDelegate)
    {
        pDelegate->textViewTextChanged(gettextViewImplIOS()->getTextView(),gettextViewImplIOS()->getText());
    }
#if CC_ENABLE_SCRIPT_BINDING
    cocos2d::ui::UITextView*  pTextView= gettextViewImplIOS()->getTextView();
    if (NULL != pTextView && 0 != pTextView->getScriptTextViewHandler()){
        cocos2d::CommonScriptData data(pTextView->getScriptTextViewHandler(),"changed",pTextView);
        cocos2d::ScriptEvent event(cocos2d::kCommonEvent,(void*)&data);
        cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
    }
#endif
}
@end
//MARK:Cpp Part
NS_CC_BEGIN

namespace ui {
    
UITextViewImpl* __createSystemTextView(UITextView* textView)
{
    return new UITextViewImplIOS(textView);
}
 
UITextViewImplIOS::UITextViewImplIOS(UITextView *textView)
:UITextViewImpl(textView)
, _label(nullptr)
, _labelPlaceHolder(nullptr)
, _anchorPoint(Vec2(0.5f, 0.5f))
, _systemControl(nullptr)
, _maxTextLength(-1)
{
    auto view = cocos2d::Director::getInstance()->getOpenGLView();
    
    _inRetinaMode = view->isRetinaDisplay();
}
    
UITextViewImplIOS::~UITextViewImplIOS()
{
    [_systemControl release];
}

void UITextViewImplIOS::doAnimationWhenKeyboardMove(float duration, float distance)
{
    if ([_systemControl isEditState] || distance < 0.0f)
    {
        [_systemControl doAnimationWhenKeyboardMoveWithDuration:duration distance:distance];
    }
}

bool UITextViewImplIOS::initWithSize(const Size& size)
{
    do
    {
        auto glview = cocos2d::Director::getInstance()->getOpenGLView();
        
        CGRect rect = CGRectMake(0, 0, size.width * glview->getScaleX(),size.height * glview->getScaleY());
        if (_inRetinaMode)
        {
            rect.size.width /= 2.0f;
            rect.size.height /= 2.0f;
            
        }
        
        _systemControl = [[CCTextViewImplIOS_objc alloc] initWithFrame:rect textView:this];
        if (!_systemControl) break;
        initInactiveLabels(size);
        setContentSize(size);
        
        return true;
    }while (0);
    
    return false;
}
 
void UITextViewImplIOS::initInactiveLabels(const Size& size)
{
    const char* pDefaultFontName = [[_systemControl.textView.font fontName] UTF8String];
    
    _label = Label::create();
    _label->setAnchorPoint(Vec2(0, 1));
    _label->setColor(Color3B::WHITE);
    _label->setVisible(false);
    _textView->addChild(_label, kLabelZOrder);
    
    _labelPlaceHolder = Label::create();
    // align the text vertically center
    _labelPlaceHolder->setAnchorPoint(Vec2(0, 1));
    _labelPlaceHolder->setColor(Color3B::GRAY);
    _textView->addChild(_labelPlaceHolder, kLabelZOrder);
    
    setPlaceholderFont(pDefaultFontName, size.height*2/3);
}
    
void UITextViewImplIOS::placeInactiveLabels()
{
    _label->setPosition(Vec2(CC_TEXT_VIEW_PADDING*2, _contentSize.height - CC_TEXT_VIEW_PADDING));
    _labelPlaceHolder->setPosition(Vec2(CC_TEXT_VIEW_PADDING*2, _contentSize.height - CC_TEXT_VIEW_PADDING));
}

void UITextViewImplIOS::setInactiveText(const char* pText)
{
    if(_systemControl.textView.secureTextEntry == YES)
    {
        std::string passwordString;
        for(int i = 0; i < strlen(pText); ++i)
            passwordString.append("\u25CF");
        _label->setString(passwordString.c_str());
    }
    else
        _label->setString(getText());
    _label->setEllipsisEabled(true);
    // Clip the text width to fit to the text box
    Size contentSize = _textView->getContentSize();
    float fMaxWidth = contentSize.width - CC_TEXT_VIEW_PADDING * 4;
    float fMaxHeight = contentSize.height - CC_TEXT_VIEW_PADDING;
    _label->setDimensions(fMaxWidth,fMaxHeight);
}

void UITextViewImplIOS::setFont(const char* pFontName, int fontSize)
{
    bool isValidFontName = true;
    if(pFontName == NULL || strlen(pFontName) == 0) {
        isValidFontName = false;
    }
    
    float retinaFactor = _inRetinaMode ? 2.0f : 1.0f;
    NSString * fntName = [NSString stringWithUTF8String:pFontName];
    fntName = [[fntName lastPathComponent] stringByDeletingPathExtension];
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    
    float scaleFactor = glview->getScaleX();
    UIFont *textFont = nil;
    if (isValidFontName) {
        textFont = [UIFont fontWithName:fntName size:fontSize * scaleFactor / retinaFactor];
    }
    
    if (!isValidFontName || textFont == nil){
        textFont = [UIFont systemFontOfSize:fontSize * scaleFactor / retinaFactor];
    }
    
    if(textFont != nil) {
        [_systemControl.textView setFont:textFont];
    }
     //修改不使用系统渲染字体?
//        TTFConfig ttfConfig(pFontName,fontSize,GlyphCollection::DYNAMIC);
//        _label->setTTFConfig(ttfConfig);
//        _labelPlaceHolder->setTTFConfig(ttfConfig);
   
        _label->setSystemFontName(pFontName);
        _label->setSystemFontSize(fontSize);
        _labelPlaceHolder->setSystemFontName(pFontName);
        _labelPlaceHolder->setSystemFontSize(fontSize);
}

void UITextViewImplIOS::setFontColor(const Color3B& color)
{
    _systemControl.textView.textColor = [UIColor colorWithRed:color.r / 255.0f green:color.g / 255.0f blue:color.b / 255.0f alpha:1.0f];
    _label->setColor(color);
}
    
void UITextViewImplIOS::setPlaceholderFont(const char* pFontName, int fontSize)
{
    // TODO need to be implemented.
}

void UITextViewImplIOS::setPlaceholderFontColor(const Color3B& color)
{
    _labelPlaceHolder->setColor(color);
}

void UITextViewImplIOS::setInputMode(EditBox::InputMode inputMode)
{
    switch (inputMode)
    {
        case EditBox::InputMode::EMAIL_ADDRESS:
            _systemControl.textView.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case EditBox::InputMode::NUMERIC:
            _systemControl.textView.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case EditBox::InputMode::PHONE_NUMBER:
            _systemControl.textView.keyboardType = UIKeyboardTypePhonePad;
            break;
        case EditBox::InputMode::URL:
            _systemControl.textView.keyboardType = UIKeyboardTypeURL;
            break;
        case EditBox::InputMode::DECIMAL:
            _systemControl.textView.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case EditBox::InputMode::SINGLE_LINE:
            _systemControl.textView.keyboardType = UIKeyboardTypeDefault;
            break;
         case EditBox::InputMode::ASCII_CAPABLE:
            _systemControl.textView.keyboardType = UIKeyboardTypeASCIICapable;
            break;
        default:
            _systemControl.textView.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

void UITextViewImplIOS::setMaxLength(int maxLength)
{
    _maxTextLength = maxLength;
}

int UITextViewImplIOS::getMaxLength()
{
    return _maxTextLength;
}

void UITextViewImplIOS::setInputFlag(EditBox::InputFlag inputFlag)
{
    switch (inputFlag)
    {
        case EditBox::InputFlag::PASSWORD:
            _systemControl.textView.secureTextEntry = YES;
            break;
        case EditBox::InputFlag::INITIAL_CAPS_WORD:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
            break;
        case EditBox::InputFlag::INITIAL_CAPS_SENTENCE:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            break;
        case EditBox::InputFlag::INTIAL_CAPS_ALL_CHARACTERS:
            _systemControl.textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            break;
        case EditBox::InputFlag::SENSITIVE:
            _systemControl.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            break;
        default:
            break;
    }
}

void UITextViewImplIOS::setReturnType(EditBox::KeyboardReturnType returnType)
{
    switch (returnType) {
        case EditBox::KeyboardReturnType::DEFAULT:
            _systemControl.textView.returnKeyType = UIReturnKeyDefault;
            break;
        case EditBox::KeyboardReturnType::DONE:
            _systemControl.textView.returnKeyType = UIReturnKeyDone;
            break;
        case EditBox::KeyboardReturnType::SEND:
            _systemControl.textView.returnKeyType = UIReturnKeySend;
            break;
        case EditBox::KeyboardReturnType::SEARCH:
            _systemControl.textView.returnKeyType = UIReturnKeySearch;
            break;
        case EditBox::KeyboardReturnType::GO:
            _systemControl.textView.returnKeyType = UIReturnKeyGo;
            break;
        default:
            _systemControl.textView.returnKeyType = UIReturnKeyDefault;
            break;
    }
}

bool UITextViewImplIOS::isEditing()
{
    return [_systemControl isEditState] ? true : false;
}

void UITextViewImplIOS::refreshInactiveText()
{
    const char* text = getText();
    if(_systemControl.textView.hidden == YES)
    {
        setInactiveText(text);
        if(strlen(text) == 0)
        {
            _label->setVisible(false);
            _labelPlaceHolder->setVisible(true);
        }
        else
        {
            _label->setVisible(true);
            _labelPlaceHolder->setVisible(false);
        }
    }
}

void UITextViewImplIOS::setEnable(bool enable)
{
    [_systemControl.textView setUserInteractionEnabled:enable?YES:NO];
}

void UITextViewImplIOS::setText(const char* text)
{
    NSString* nsText =[NSString stringWithUTF8String:text];
    if ([nsText compare:_systemControl.textView.text] != NSOrderedSame)
    {
        _systemControl.textView.text = nsText;
    }
    
    refreshInactiveText();
}

extern NSString* removeSiriString(NSString* str);
const char*  UITextViewImplIOS::getText(void)
{
    return [removeSiriString(_systemControl.textView.text) UTF8String];
}

void UITextViewImplIOS::setPlaceHolder(const char* pText)
{
    //    _systemControl.textView.placeholder = [NSString stringWithUTF8String:pText];
    _labelPlaceHolder->setString(pText);
    Size labelSize = _labelPlaceHolder->getContentSize();
    _labelPlaceHolder->setDimensions(_textView->getContentSize().width,0);
    
}

static CGPoint convertDesignCoordToScreenCoord(const Vec2& designCoord, bool bInRetinaMode)
{
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview = (CCEAGLView *) glview->getEAGLView();
    
    float viewH = (float)[eaglview getHeight];
    
    Vec2 visiblePos = Vec2(designCoord.x * glview->getScaleX(), designCoord.y * glview->getScaleY());
    Vec2 screenGLPos = visiblePos + glview->getViewPortRect().origin;
    
    CGPoint screenPos = CGPointMake(screenGLPos.x, viewH - screenGLPos.y);
    
    if (bInRetinaMode)
    {
        screenPos.x = screenPos.x / 2.0f;
        screenPos.y = screenPos.y / 2.0f;
    }
    CCLOGINFO("[TextView] pos x = %f, y = %f", screenGLPos.x, screenGLPos.y);
    return screenPos;
}

void UITextViewImplIOS::setPosition(const Vec2& pos)
{
    _position = pos;
    adjustTextFieldPosition();
}

void UITextViewImplIOS::setVisible(bool visible)
{
    //    _systemControl.textField.hidden = !visible;
}

void UITextViewImplIOS::setContentSize(const Size& size)
{
    _contentSize = size;
    CCLOG("[TextView text] content size = (%f, %f)", size.width, size.height);
    placeInactiveLabels();
    auto glview = cocos2d::Director::getInstance()->getOpenGLView();
    CGSize controlSize = CGSizeMake(size.width * glview->getScaleX(),size.height * glview->getScaleY());
    
    if (_inRetinaMode)
    {
        controlSize.width /= 2.0f;
        controlSize.height /= 2.0f;
    }
    [_systemControl setContentSize:controlSize];
}

void UITextViewImplIOS::setAnchorPoint(const Vec2& anchorPoint)
{
    CCLOG("[TextView text] anchor point = (%f, %f)", anchorPoint.x, anchorPoint.y);
    _anchorPoint = anchorPoint;
    setPosition(_position);
}

void UITextViewImplIOS::visit(void)
{
}

void UITextViewImplIOS::onEnter(void)
{
    adjustTextFieldPosition();
    const char* pText = getText();
    if (pText) {
        setInactiveText(pText);
    }
}

void UITextViewImplIOS::updatePosition(float dt)
{
    if (nullptr != _systemControl) {
        this->adjustTextFieldPosition();
    }
}



void UITextViewImplIOS::adjustTextFieldPosition()
{
    Size contentSize = _textView->getContentSize();
    Rect rect = Rect(0, 0, contentSize.width, contentSize.height);
    rect = RectApplyAffineTransform(rect, _textView->nodeToWorldTransform());
    
    Vec2 designCoord = Vec2(rect.origin.x+CC_TEXT_VIEW_PADDING, rect.origin.y + rect.size.height - CC_TEXT_VIEW_PADDING);
    [_systemControl setPosition:convertDesignCoordToScreenCoord(designCoord, _inRetinaMode)];
}

void UITextViewImplIOS::openKeyboard()
{
    _label->setVisible(false);
    _labelPlaceHolder->setVisible(false);
    
    _systemControl.textView.hidden = NO;
    [_systemControl openKeyboard];
}

void UITextViewImplIOS::closeKeyboard()
{
    [_systemControl closeKeyboard];
}

void UITextViewImplIOS::onEndEditing()
{
    _systemControl.textView.hidden = YES;
    if(strlen(getText()) == 0)
    {
        _label->setVisible(false);
        _labelPlaceHolder->setVisible(true);
    }
    else
    {
        _label->setVisible(true);
        _labelPlaceHolder->setVisible(false);
        setInactiveText(getText());
    }
}


}
NS_CC_END
#endif/* #if (..) */
