#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,getopt,codecs
import traceback
from xml.dom.minidom import parse
import xml.dom.minidom

def usage():
    print '''使用方式:
    ./tmxmap2lua.py -i file -o outfile
    '''



if __name__=="__main__":
	dest_dir = '../../dev/res/tmxmaps'

	try:
		opts,args = getopt.getopt(sys.argv[1:], 'i:o:')
	except getopt.GetoptError, err:
		usage()
		sys.exit(2)

	if len(opts) == 0:
		usage()
		sys.exit(2)

	sourcefile = None
	destfile = None
	for opt, arg in opts:
		if opt == '-i':
			sourcefile = arg
		elif opt == '-o':
			destfile = arg

	# print sourcefile, dest_dir+"/"+destfile
	DOMTree = xml.dom.minidom.parse(sourcefile)
	print(dir(DOMTree.documentElement), DOMTree.documentElement)
	if DOMTree.documentElement.getAttribute("orientation") != "orthogonal":
		print("不支持这种坐标格式")
		sys.exit(3)
	print(DOMTree.documentElement.getAttribute("width"))
	print(DOMTree.documentElement.getAttribute("height"))
	print(DOMTree.documentElement.getAttribute("tilewidth"))
	print(DOMTree.documentElement.getAttribute("tileheight"))

	print(len(DOMTree.documentElement.getElementsByTagName("tileset")))
	print(DOMTree.documentElement.getElementsByTagName("tileset").item(0).getAttribute("firstgid"))
	for tile in DOMTree.documentElement.getElementsByTagName("tileset").item(0).getElementsByTagName("tile"):
		print "tile", tile.getAttribute("id")
		for property in tile.getElementsByTagName("properties").item(0).getElementsByTagName("property"):
			print "name", "value", property.getAttribute("name"), property.getAttribute("value")

	assert DOMTree.documentElement.getElementsByTagName("layer").item(0).getElementsByTagName("data").item(0).getAttribute("encoding") == "csv"
	print("===")
	print(DOMTree.documentElement.getElementsByTagName("layer")[0].getElementsByTagName("data")[0].childNodes[0].data)
	for obj in DOMTree.documentElement.getElementsByTagName("objectgroup")[0].getElementsByTagName("object"):
		print(obj.getAttribute("x"), obj.getAttribute("y"))
		print(obj.getElementsByTagName("polyline")[0].getAttribute("points"))
			






