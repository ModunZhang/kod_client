#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,getopt,codecs,types,traceback,json

def usage():
    print '''使用方式:
    ./build_animation.py -o outfile
    '''

if __name__=="__main__":
	dest_dir = '../../dev/res/scripts/app'

	try:
		opts,args = getopt.getopt(sys.argv[1:], 'o:')
	except getopt.GetoptError, err:
		usage()
		sys.exit(2)

	if len(opts) == 0:
		usage()
		sys.exit(2)

	destfile = None
	for opt, arg in opts:
		if opt == '-o':
			destfile = arg

	D = {}
	for root, dirs, files in os.walk('../../dev/res/animations/'):
		for fileName in files:
			sufix = os.path.splitext(fileName)[1][1:]
			if sufix == "ExportJson":
				with codecs.open(root + fileName, 'r', 'utf-8') as f:
					source = f.read() 
					target = json.JSONDecoder().decode(source)  
					D[os.path.splitext(fileName)[0]] = target['config_png_path']

	with codecs.open('../../dev/scripts/app/' + destfile, 'w', 'utf-8') as f:
		f.write('local animation = {}\n')
		for (k,v) in D.items():
			f.write("animation[\"%s\"] = {%s}\n" % (k, ",".join([ '\"animations/'+item+'\"' for item in v])))
		f.write('return animation')





