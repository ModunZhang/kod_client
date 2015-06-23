#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,getopt,codecs
import traceback

def usage():
    print '''使用方式:
    ./build_format_map.py -r dest_file_name
    或
    ./build_format_map.py -j dest_file_name
    会在../../dev/scripts/app/中生成对应文件
        '''

if __name__=="__main__":
	images_dir = '../../dev/res/images/'
	resource_dir = '../../dev/res/images/rgba444_single'
	dest_dir = '../../dev/scripts/app/'

	try:
		opts,args = getopt.getopt(sys.argv[1:], 'j:r:')
	except getopt.GetoptError, err:
		# print str(err) # will print something like "option -a not recognized"
		usage()
		sys.exit(2)

	if len(opts) == 0:
		usage()
		sys.exit(2)		

	jpg = False
	rgba444 = False
	dest_file = None
	for opt, arg in opts:
		if not arg:
			sys.exit(-1)
		if opt == '-r':
			dest_file = arg
			rgba444 = True
		elif opt == '-j':
			dest_file = arg
			jpg = True
		else:
			assert False, "unhandled option"

	if jpg:
		with codecs.open(dest_dir + dest_file, 'w', 'utf-8') as f:
			basename, _ = os.path.splitext(dest_file)
			for root, dirs, files in os.walk(images_dir):
				if root == images_dir:
					f.write('local %s = {}\n' % basename)
					for fileName in files:
						sufix = os.path.splitext(fileName)[1][1:]
						if sufix == "jpg":
							f.write('%s["%s"] = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888\n' % (basename, fileName) )
					f.write('return %s' % basename)
	elif rgba444:
		try:
			with codecs.open(dest_dir + dest_file, 'w', 'utf-8') as f:
				_, file_name = os.path.split(resource_dir)
				f.write('local %s = {}\n' % file_name)
				for root, dirs, files in os.walk(resource_dir):
					for fileName in files:
						f.write('%s["%s"] = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444\n' % (file_name, fileName) )
				f.write('return %s' % file_name)
		except:
			sys.exit()







