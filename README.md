# 2dx版本3.3final升级
---- 
---- 
- 修改editbox iOS支持编辑时清除内容
	> textField_.clearButtonMode = UITextFieldViewModeWhileEditing;
- 修改ios单行输入框的行为 修改editbox ended事件
- 修改ios下背景音乐的播放规则
- 键盘弹出事件修改
- 文本框和quick事件冲突修复(CCNode)
- 修改文本框占位文字的格式bug
	> _labelPlaceHolder-\>setSystemFontName(pFontName);
	> _labelPlaceHolder-\>setSystemFontSize(fontSize);
- 添加多行输入框
- GameCenter
- iap添加接口
- 资源加密脚本修改(quick) 修改图片读取函数(CCImage)用以支持资源加密
- 开启quick项目的luac加密模式，未加密的原配置备份文件为
	1. v3.3/external/lua/lua/lopcodes.def_bak_20150304-111302
	2. v3.3/external/lua/lua/lopmodes.def_bak_20150304-111302
- 添加图片处理命令行工具
- `输入框使用项目自定义的字体(放弃修改)`
- Label加粗功能(还未修改)

