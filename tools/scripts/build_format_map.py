#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,getopt,codecs

def usage():
    print '''使用方式:
    ./build_format_map.py -d dest_file_name
    会在../../dev/scripts/app/中生成
        '''



if __name__=="__main__":
	resource_dir = '../../dev/res/images/rgba444_single'
	dest_dir = '../../dev/scripts/app/'

	if len(sys.argv) < 2:
		usage()
		sys.exit()

	try:
		opts,args = getopt.getopt(sys.argv[1:], 'd:')
	except getopt.GetoptError:
		sys.exit()

	lua_file = None
	for opt, arg in opts:
		if opt == '-d':
			if not arg:
				sys.exit(-1)
			lua_file = arg

	try:
		with codecs.open(dest_dir + lua_file, 'w', 'utf-8') as f:
			_, file_name = os.path.split(resource_dir)
			f.write('local %s = {}\n' % file_name)
			for root, dirs, files in os.walk(resource_dir):
				for fileName in files:
					f.write('%s["%s"] = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444\n' % (file_name, fileName) )
			f.write('return %s' % file_name)
	except:
		sys.exit()







