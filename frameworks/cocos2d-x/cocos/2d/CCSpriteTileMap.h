//
//  CCSpriteTileMap.h
//  cocos2d_libs
//
//  Created by DannyHe on 4/24/15.
//
//

#ifndef __cocos2d_libs__CCSpriteTileMap__
#define __cocos2d_libs__CCSpriteTileMap__
#include "2d/CCSprite.h"

NS_CC_BEGIN

class SpriteTileMap : public Sprite
{
public:
    static SpriteTileMap* createWithTexture(Texture2D *texture, const Rect& rect, bool rotated=false);
protected:
    virtual void setTextureCoords(Rect rect) override;
};

NS_CC_END
#endif /* defined(__cocos2d_libs__CCSpriteTileMap__) */
