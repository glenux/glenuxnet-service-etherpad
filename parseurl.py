#!/usr/bin/env python

import sys
import os
from urlparse import urlparse

prefix = sys.argv[1]
# print os.environ.keys
uri_str = os.environ['DATABASE_URL']
uri = urlparse(uri_str)

db_netloc = uri.netloc 

db_credential = None
db_username = None
db_password = None
db_host = None
db_port = None

if db_netloc.find("@") >= 0 :
  tmp_arr1 = db_netloc.split('@')
  db_credential = tmp_arr1[0]
  db_host = tmp_arr1[1]

if db_credential and db_credential.find(':') >= 0 :
  tmp_arr2 = db_credential.split(':')
  db_username = tmp_arr2[0]
  db_password = tmp_arr2[1]

if db_host and db_host.find(':') >= 0 :
  tmp_arr3 = db_host.split(':')
  db_host = tmp_arr3[0]
  db_port = tmp_arr3[1]

db_path = uri.path
db_scheme = uri.scheme 
db_query = uri.query
db_fragment = uri.fragment

if db_scheme :
  print(prefix + 'SCHEME=' + db_scheme)

if db_username :
  print(prefix + 'USERNAME=' + db_username)

if db_password :
  print(prefix + 'PASSWORD=' + db_password)

if db_host :
  print(prefix + 'HOST=' + db_host)

if db_port :
  print(prefix +  'PORT=' + db_port)

if db_path :
  print(prefix + 'DATABASE=' + db_path)

if db_query :
  print(prefix + 'QUERY=' + db_query)

if db_fragment :
  print(prefix + 'FRAGMENT=' + db_fragment)

