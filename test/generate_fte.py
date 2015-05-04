#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import codecs
import traceback

key_map = {
    ".": 1,
    "[": 1,
    "]": 1,
    "\"": 1,
    "(": 1,
    ")": 1,
    ",": 1,
    "&": 1,
}
next_symbol = '&'
replace_map = {
	'->': next_symbol,
	'\t': '',
	'\n': '',
}
tokens = []
cur_token_index = 0
with codecs.open('./fte.lua', 'w', 'utf-8') as lua_file:
	def parse_tokens(fte_str):
		for k, v in replace_map.iteritems():
			fte_str = fte_str.replace(k, v)
		token_stream = []
		cur_word = []
		in_comma = False
		for i, letter in enumerate(fte_str):
			try:
				if letter == "\"":
					in_comma = not in_comma
					if in_comma:
						continue
					else:
						token_stream.append(letter)
				if in_comma:
					cur_word.append(letter)
					continue
				if key_map[letter]:
					if cur_word:
						token_stream.append(''.join(cur_word).strip())
					cur_word = []
					token_stream.append(letter)
			except KeyError, e:
				cur_word.append(letter)

		if cur_word:
			token_stream.append(''.join(cur_word).strip())
		return token_stream

	def emit(*code):
		lua_file.write(*code)

	def look_token():
		try:
			return tokens[cur_token_index]
		except IndexError, e:
			print "已经完了"
			return None

	def look_ahead(token):
		return token == look_token()

	def match(token):
		if not look_ahead(token):
			s = "%s 不匹配" % token
			raise Exception(s)
		global cur_token_index
		cur_token_index += 1
		return token

	def match_current():
		return match(look_token())

	def match_next():
		emit(":next(function(result)\n")
		emit("\treturn\t")
		match_token()
		emit("\nend)")

	def match_sub():
		match(next_symbol)
		match_next()

	def match_check_next():
		emit(":next(function(result)\n")
		match_check()
		emit("\n\treturn\t")
		match(next_symbol)
		match_token()
		emit("\nend)")	

	def match_dot():
		match(".")
		if look_ahead("check"):
			match_check_next()
		else:			
			match_next()

	def match_equip():
		match("equip")
		emit("City:PromiseOfFinishEquipementDragon()")

	def match_recruit():
		match("recruit")
		match("(")
		try:
			soldier_type = str(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "progress 必须传入 0 ~ 100"
			return
		emit("City:PromiseOfRecruitSoldier(\"%s\")" % soldier_type)
		match(")")

	def match_progress():
		match("progress")
		match("(")
		try:
			percent = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "progress 必须传入 0 ~ 100"
			return
		emit("result:PromiseOfProgress(%s)" % percent)
		match(")")

	def match_unlock():
		match("unlock")
		match("(")
		try:
			building_type = str(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "unlock 必须传入建筑类型"
			return
		emit("self:GetLockButtonsByBuildingType(\"%s\")" % building_type)
		match(")")

	def match_check():
		match("check")
		match("(")
		try:
			step = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "check 必须传入数字"
			return
		emit("\tif check(%s) then return cocos_promise.defer(function() return result end) end" % step)
		match(")")

	def match_finish():
		match("finish")
		match("(")
		try:
			building_type = str(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "finish building_type building_level"
			return
		if look_ahead(","):
			match(",")
		else:
			emit("City:PromiseOfFinishUpgradingByLevel(\"%s\")" % building_type)
			match(")")
			return

		building_level = 0
		try:
			building_level = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "finish building_type building_level"
			return
		emit("City:PromiseOfFinishUpgradingByLevel(\"%s\", %s)" % (building_type, building_level))
		match(")")

	def match_upgrade():
		match("upgrade")
		match("(")
		try:
			building_type = str(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "upgrade building_type building_level"
			return
		if look_ahead(","):
			match(",")
		else:
			emit("City:PromiseOfUpgradingByLevel(\"%s\")" % building_type)
			match(")")
			return

		building_level = 0
		try:
			building_level = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "upgrade building_type building_level"
			return
		emit("City:PromiseOfUpgradingByLevel(\"%s\", %s)" % (building_type, building_level))
		match(")")

	def match_show():
		match("show")
		match("(")
		if not look_ahead(")"):
			emit("scene:GetHomePage():DefferShow(\"%s\")" % match_current())
		match(")")

	def match_arrowOn():
		match("arrowOn")
		if look_ahead("("):
			match("(")
		else:
			emit("scene:GetArrowTutorial():DefferShow(result)")
			return

		try:
			angle = int(look_token())
			match_current()
		except ValueError, e:
			if look_ahead(")"):
				emit("scene:GetArrowTutorial():DefferShow(result)")
				match(")")
				return
			traceback.print_exc()
			print "arrowOn angle offsetx offsety"
			return

		if look_ahead(","):
			match(",")
		elif look_ahead(")"):
			match(")")
			emit("scene:GetArrowTutorial():DefferShow(result, %s)" % angle)
			return

		try:
			x = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "arrowOn angle offsetx offsety"
			return

		if look_ahead(","):
			match(",")
		elif look_ahead(")"):
			match(")")
			emit("scene:GetArrowTutorial():DefferShow(result, %s, %s)" % (angle, x))
			return

		try:
			y = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "arrowOn angle offsetx offsety"
			return
		emit("scene:GetArrowTutorial():DefferShow(result, %s, %s, %s)" % (angle, x, y))
		match(")")
	
		

	def match_arrowOff():
		match("arrowOff")
		emit("scene:DestoryArrowTutorial(function() return result end)")

	def match_setup():
		match("setup")
		emit("cocos_promise.defer(function() return result end)")

	def match_delay():
		match("delay")
		if look_ahead("("):
			match("(")
		else:
			emit("cocos_promise.defer(function() return result end)")
			return

		try:
			t = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "delay 秒"
			return
		emit("cocos_promise.Delay(%s, function() return result end)" % t)
		match(")")
		

	def match_quit():
		match("quit")
		emit("GameUINpc:PromiseOfLeave()")

	def match_find():
		match("find")
		match("(")
		if not look_ahead(")"):
			emit("result:Find(\"%s\")" % match_current())
		else:
			emit("result:Find()")
		match(")")


	def match_waitTag():
		match("waitTag")
		match("(")
		try:
			ui_name = str(look_token())
			match_current()
			match(",")
			tag_name = str(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "waitTag 必须传入 ui 名字, tag 名字"
			return
		emit("UIKit:GetUIInstance(\"%s\"):WaitTag(\"%s\")" % (ui_name, tag_name))
		match(")")

	def match_wait():
		match("wait")
		match("(")
		if not look_ahead(")"):
			emit("UIKit:PromiseOfOpen(\"%s\")" % match_current())
		match(")")

	def match_lock():
		match("lock")
		emit("result:Lock()")

	def match_click():
		match("click")
		match("(")
		try:
			x = int(look_token())
			match_current()
			match(",")
			y = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "click 必须传入数字"
			return
		emit("scene:PromiseOfClickBuilding(%s, %s)" % (x, y))
		match(")")

	def match_input():
		match("input")
		emit("GameUINpc:PromiseOfInput()")

	def match_move():
		match("move")
		match("(")
		try:
			x = int(look_token())
			match_current()
			match(",")
			y = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "move x, y"
			return

		if look_ahead(","):
			match(",")
		else:
			emit("scene:GotoLogicPoint(%s, %s)" % (x, y))
			match(")")
			return

		try:
			s = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "move x, y, speed"
			return
		if s <= 0:
			emit("scene:GotoLogicPointInstant(%s, %s)" % (x, y))
		else:
			emit("scene:GotoLogicPoint(%s, %s, %s)" % (x, y, s))
		match(")")

	def match_say():
		match("say")
		match("(")
		match("\"")
		emit("GameUINpc:PromiseOfSay({")
		emit("words = \"")
		if not look_ahead("\""):
			emit(match_current())
		emit("\"")
		emit("})")
		match("\"")
		match(")")


	def match_all():
		match("all")
		match("[")
		emit("promise.all(")
		match_any()
		emit(")")
		match("]")

	def match_deffer():
		match("defer")
		emit("cocos_promise.defer()")

	def match_any():
		match_in_all()
		if look_ahead(","):
			match(",")
			emit(", ")
			match_any()


	def match_in_all():
		match_token()
		if look_ahead("."):
			match_dot()
			if look_ahead(","):
				return
			else:
				match_in_all()

	def match_token():
		if look_ahead("defer"):
			match_deffer()
		elif look_ahead("all"):
			match_all()
		elif look_ahead("say"):
			match_say()
		elif look_ahead("move"):
			match_move()
		elif look_ahead("input"):
			match_input()
		elif look_ahead("click"):
			match_click()
		elif look_ahead("wait"):
			match_wait()
		elif look_ahead("waitTag"):
			match_waitTag()
		elif look_ahead("lock"):
			match_lock()
		elif look_ahead("find"):
			match_find()
		elif look_ahead("quit"):
			match_quit()
		elif look_ahead("delay"):
			match_delay()
		elif look_ahead("setup"):
			match_setup()
		elif look_ahead("arrowOn"):
			match_arrowOn()
		elif look_ahead("arrowOff"):
			match_arrowOff()
		elif look_ahead("upgrade"):
			match_upgrade()
		elif look_ahead("finish"):
			match_finish()
		elif look_ahead("show"):
			match_show()
		elif look_ahead("check"):
			match_check()
		elif look_ahead("unlock"):
			match_unlock()
		elif look_ahead("progress"):
			match_progress()
		elif look_ahead("recruit"):
			match_recruit()
		elif look_ahead("equip"):
			match_equip()
			## 
		elif look_ahead("corps"):
			match_corps()
		elif look_ahead("moveTo"):
			match_moveTo()
		elif look_ahead("idle"):
			match_idle()
		elif look_ahead("speak"):
			match_speak()
		elif look_ahead("shoutUp"):
			match_shoutUp()
		if look_ahead(next_symbol):
			match_sub()


	def match_corps():
		match("corps")
		match("(")
		try:
			index = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "corps 必须传入 1 ~ 6"
			return
		emit("self:DefferGetCorps(%s)" % index)
		match(")")

	def match_moveTo():
		match("moveTo")
		match("(")
		try:
			x = int(look_token())
			match_current()
			match(",")
			y = int(look_token())
			match_current()
			match(",")
			t = int(look_token())
			match_current()
		except ValueError, e:
			traceback.print_exc()
			print "moveTo 必须传入数字"
			return

		emit("result:move(%s, self.normal_map:ConvertToMapPosition(%s, %s))" % (x, y, t))
		match(")")


	def match_idle():
		match("idle")
		emit("result:breath(true)")


	def match_speak():
		match("speak")
		match("(")
		match("\"")
		emit("result:PromiseOfSay({")
		emit("words = \"")
		if not look_ahead("\""):
			emit(match_current())
		emit("\"")
		emit("})")
		match("\"")
		match(")")

	def match_shoutUp():
		match("shoutUp")
		emit("result:PromiseOfShoutUp()")

	def match_start():
		while 1:
			if look_token() == None:
				return
			match_token()
			if look_ahead("."):
				match_dot()
		
	try:
		fte_file_name = './test1.fte'
		if len(sys.argv) > 1:
			fte_file_name = sys.argv[1]

		with codecs.open(fte_file_name, 'r', 'utf-8') as f:
			tokens = parse_tokens(f.read())
			# print tokens
			match_start()

	except IOError, e:
		print "未找到文件!"



