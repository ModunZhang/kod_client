# -*- coding: utf-8 -*-
import os
import json
import string
import subprocess

global m_currentDir

def getFileTag( fullPath ):
	bashCommand = "git log -1 --pretty=format:%h -- path " + fullPath
	process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
	output = process.communicate()[0].rstrip()
	return output

def getFileSvnPath( fullPath ):
	bashCommand = "git ls-tree --name-only --full-name HEAD " + fullPath
	process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
	output = process.communicate()[0].rstrip()
	output = output[7:]
	return output

def getFileSize( fullPath ):
	return os.path.getsize(fullPath)

def getFileCrc32( fullPath ):
	bashCommand = m_currentDir + "/crc32 " + fullPath
	process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
	output = process.communicate()[0].rstrip()
	return output

def browseFolder( fullPath, fileList ):
	for root, dirs, files in os.walk(fullPath):
		for fileName in files:
			if fileName != ".DS_Store" and fileName != "fileList.json":
				# print("检查文件 " + root + "/" + fileName)
				path = root + "/" + fileName
				svnPath = getFileSvnPath(path)
				tag = getFileTag(path)
				size = getFileSize(path)
				crc32 = getFileCrc32(path)
				fileList["files"][svnPath] = {
					"tag":tag,
					"size":size,
					"crc32":crc32
				}

def writeJsonFile( fileList ):
	fileJson = json.dumps(fileList)
	jsonFile = open("../../update/res/fileList.json", 'w')
	jsonFile.write(fileJson)
	jsonFile.close()

def getAppVersion():
	configFile = open("../../update/scripts/config.lua")
	appVersion = ""
	for line in configFile:
		if "CONFIG_APP_VERSION" in line:
			line = line.rstrip()
			appVersion = line[-6:-1]
	configFile.close()
	return appVersion

if __name__=="__main__":
	m_currentDir = os.path.dirname(os.path.realpath(__file__))
	fileList = {
		"appVersion":getAppVersion(),
		"tag":getFileTag("../../update/"),
		"files":{},
	}
	browseFolder("../../update/res", fileList)
	browseFolder("../../update/scripts", fileList)
	fileJson = json.dumps(fileList)
	writeJsonFile(fileList)