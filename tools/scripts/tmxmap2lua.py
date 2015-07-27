#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,getopt,codecs,types
import traceback
from xml.dom.minidom import parse
import xml.dom.minidom

def usage():
    print '''使用方式:
    ./tmxmap2lua.py -i file -o outfile
    '''

def str2str(str):
	pass
def int2int(str):
	pass
def dic2table(dct):
	dct_str = "{"
	for k,v in dct.items():
		dct_str += "\n"
		if type(k) is types.StringType:
			if type(v) is types.IntType:
				dct_str += "%s = %s," % (k,v)
			elif type(v) is types.StringType:
				dct_str += "%s = \"%s\"," % (k,v)
			elif type(v) is types.DictType:
				dct_str += "%s = %s," % (k,dic2table(v))
			elif type(v) is types.ListType:
				dct_str += "%s = %s," % (k, array2table(v))
			elif type(v) is types.UnicodeType:
				dct_str += "%s = \"%s\"," % (k,v)
			else:
				assert(False)
		else:
			# assert(False)
			pass
		dct_str += "\n"
	dct_str += "}\n"
	return dct_str
def array2table(a):
	arr_str = "{"
	for i in range(0, len(a)):
		if type(a[i]) is types.IntType:
			arr_str += "%d," % a[i]
		elif type(a[i]) is types.StringType:
			arr_str += "\"%s\"," % a[i]
		elif type(a[i]) is types.DictType:
			arr_str += "%s," % dic2table(a[i])
		elif type(a[i]) is types.ListType:
			arr_str += array2table(a[i])
		elif type(a[i]) is types.UnicodeType:
			arr_str += "%s," % a[i]
		else:
			assert(False)
	arr_str += "}\n"
	return arr_str



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

	DOMTree = xml.dom.minidom.parse(sourcefile)
	if DOMTree.documentElement.getAttribute("orientation") != "orthogonal":
		print("不支持这种坐标格式")
		sys.exit(3)
			
	pve_map = {}
	pve_map["width"] = int(DOMTree.documentElement.getAttribute("width"))
	pve_map["height"] = int(DOMTree.documentElement.getAttribute("height"))
	pve_map["tilewidth"] = int(DOMTree.documentElement.getAttribute("tilewidth"))
	pve_map["tileheight"] = int(DOMTree.documentElement.getAttribute("tileheight"))
	pve_map["tilesets"] = []
	for i in range(0, DOMTree.documentElement.getElementsByTagName("tileset").length):
		pve_map["tilesets"].append({})
		pve_map["tilesets"][i]["firstgid"] = int(DOMTree.documentElement.getElementsByTagName("tileset")[i].getAttribute("firstgid"))
		tiles = []
		for tile_i in range(0, DOMTree.documentElement.getElementsByTagName("tileset")[i].getElementsByTagName("tile").length):
			tiles.append({})
			tiles[tile_i]["id"] = int(DOMTree.documentElement.getElementsByTagName("tileset")[i].getElementsByTagName("tile")[tile_i].getAttribute("id"))
			properties = {}
			for p_i in range(0, DOMTree.documentElement.getElementsByTagName("tileset")[i].getElementsByTagName("tile")[tile_i].getElementsByTagName("properties")[0].getElementsByTagName("property").length):
				item = DOMTree.documentElement.getElementsByTagName("tileset")[i].getElementsByTagName("tile")[tile_i].getElementsByTagName("properties")[0].getElementsByTagName("property")[p_i]
				properties[item.getAttribute("name")] = item.getAttribute("value")
			tiles[tile_i]["properties"] = properties
		pve_map["tilesets"][i]["tiles"] = tiles

	pve_map["layers"] = []
	for i in range(0, DOMTree.documentElement.getElementsByTagName("layer").length):
		pve_map["layers"].append({})
		pve_map["layers"][i]["type"] = "tilelayer"
		pve_map["layers"][i]["name"] = DOMTree.documentElement.getElementsByTagName("layer")[i].getAttribute("name")
		data = DOMTree.documentElement.getElementsByTagName("layer")[i].getElementsByTagName("data")[0].childNodes[0].data
		array = []
		line_data = data.split("\n")
		for item in line_data:
			for num in item.split(","):
				try:
					array.append(int(num))
				except Exception, e:
					pass
		pve_map["layers"][i]["data"] = array

	for i in range(len(pve_map["layers"]), len(pve_map["layers"]) + DOMTree.documentElement.getElementsByTagName("objectgroup").length):
		index = i - len(pve_map["layers"])
		pve_map["layers"].append({})
		pve_map["layers"][i]["type"] = "objectgroup"
		pve_map["layers"][i]["name"] = DOMTree.documentElement.getElementsByTagName("objectgroup")[index].getAttribute("name")

		pve_map["layers"][i]["objects"] = []
		for obj_i in range(0, DOMTree.documentElement.getElementsByTagName("objectgroup")[index].getElementsByTagName("object").length):
			pve_map["layers"][i]["objects"].append({})
			item = DOMTree.documentElement.getElementsByTagName("objectgroup")[index].getElementsByTagName("object").item(obj_i)
			if item.getElementsByTagName("polyline").length > 0:
				pve_map["layers"][i]["objects"][obj_i]["shape"] = "polyline"
			else:
				assert(False)
			pve_map["layers"][i]["objects"][obj_i]["x"] = int(item.getAttribute("x"))
			pve_map["layers"][i]["objects"][obj_i]["y"] = int(item.getAttribute("y"))
			polyline = []
			points = item.getElementsByTagName("polyline")[0].getAttribute("points").split(" ")
			for l_i in range(0, len(points)):
				polyline.append({})
				pp = points[l_i].split(",")
				polyline[l_i]["x"] = int(pp[0])
				polyline[l_i]["y"] = int(pp[1])
			pve_map["layers"][i]["objects"][obj_i]["polyline"] = polyline

	with codecs.open("pve_level.lua", 'w', 'utf-8') as f:
		f.write(dic2table(pve_map))








