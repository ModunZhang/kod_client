#!/usr/bin/env python
# -*- coding: utf-8 -*-
# deffer
# move
# say
# input
# click
# wait
# find
# all
# quit

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
tokens = []
cur_token_index = 0
next_symbol = '&'
with codecs.open('./fte.lua', 'w', 'utf-8') as lua_file:
	def parse_tokens(fte_str):
		fte_str = fte_str.replace('->',next_symbol)
		fte_str = fte_str.replace('\t','')
		fte_str = fte_str.replace('\n','')
		token_stream = []
		cur_word = []
		in_comma = False
		is_next = False
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
			print "%s 不匹配" % token
		global cur_token_index
		cur_token_index += 1
		return token

	def match_current():
		return match(look_token())

	def match_next():
		lua_file.write(":next(function(result)\n")
		lua_file.write("\treturn\t")
		match_token()
		lua_file.write("\nend)")

	def match_sub():
		match(next_symbol)
		match_next()

	def match_check_next():
		lua_file.write(":next(function(result)\n")
		match_check()
		lua_file.write("\n\treturn\t")
		match(next_symbol)
		match_token()
		lua_file.write("\nend)")	

	def match_dot():
		match(".")
		if look_ahead("check"):
			match_check_next()
		else:			
			match_next()

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
		lua_file.write("\tif check(%s) then return cocos_promise.deffer(function() return result end) end" % step)
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
			lua_file.write("City:PromiseOfFinishUpgradingByLevel(\"%s\")" % building_type)
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
		lua_file.write("City:PromiseOfFinishUpgradingByLevel(\"%s\", %s)" % (building_type, building_level))
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
			lua_file.write("City:PromiseOfUpgradingByLevel(\"%s\")" % building_type)
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
		lua_file.write("City:PromiseOfUpgradingByLevel(\"%s\", %s)" % (building_type, building_level))
		match(")")

	def match_show():
		match("show")
		match("(")
		if not look_ahead(")"):
			lua_file.write("scene:GetHomePage():DefferShow(\"%s\")" % match_current())
		match(")")

	def match_arrowOn():
		match("arrowOn")
		lua_file.write("scene:GetArrowTutorial():DefferShow(result)")

	def match_arrowOff():
		match("arrowOff")
		lua_file.write("scene:DestoryArrowTutorial()")

	def match_setup():
		match("setup")
		lua_file.write("cocos_promise.deffer(function() return result end)")

	def match_delay():
		match("delay")
		lua_file.write("cocos_promise.deffer(function() return result end)")

	def match_quit():
		match("quit")
		lua_file.write("GameUINpc:PromiseOfLeave()")

	def match_find():
		match("find")
		match("(")
		if not look_ahead(")"):
			lua_file.write("result:Find(\"%s\")" % match_current())
		else:
			lua_file.write("result:Find()")
		match(")")

	def match_wait():
		match("wait")
		match("(")
		if not look_ahead(")"):
			lua_file.write("UIKit:PromiseOfOpen(\"%s\")" % match_current())
		match(")")

	def match_lock():
		match("lock")
		lua_file.write("result:Lock()")

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
		lua_file.write("scene:PromiseOfClickBuilding(%s, %s)" % (x, y))
		match(")")

	def match_input():
		match("input")
		lua_file.write("GameUINpc:PromiseOfInput()")

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
			print "move 必须传入数字"
			return
		lua_file.write("scene:GotoLogicPoint(%s, %s)" % (x, y))
		match(")")

	def match_say():
		match("say")
		match("(")
		match("\"")
		lua_file.write("GameUINpc:PromiseOfSay({")
		lua_file.write("words = \"")
		if not look_ahead("\""):
			lua_file.write(match_current())
		lua_file.write("\"")
		lua_file.write("})")
		match("\"")
		match(")")


	def match_all():
		match("all")
		match("[")
		lua_file.write("promise.all(")
		match_any()
		lua_file.write(")")
		match("]")

	def match_deffer():
		match("deffer")
		lua_file.write("cocos_promise.deffer()")

	def match_any():
		match_in_all()
		if look_ahead(","):
			match(",")
			lua_file.write(", ")
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
		if look_ahead("deffer"):
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
		if look_ahead(next_symbol):
			match_sub()

	def match_main():
		while 1:
			if look_token() == None:
				return
			match_token()
			if look_ahead("."):
				match_dot()
		
	try:
		with codecs.open('./test.fte', 'r', 'utf-8') as f:
			tokens = parse_tokens(f.read())
			# print tokens
			match_main()

	except IOError, e:
		print "未找到文件!"



