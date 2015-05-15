# -*- coding: utf-8 -*-
import sys
import json

def outputJson(jsonFile):
	f = open(jsonFile, 'r')
	data = json.load(f)
	print('=====Python=====')
	print(data)
	f.close()

if __name__ == "__main__":
	outputJson(sys.argv[1])