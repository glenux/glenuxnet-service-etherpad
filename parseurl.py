#!/usr/bin/env python

import sys
import os
from urlparse import urlparse

prefix = sys.argv[1]
uri = os.environ['DATABASE_URL']
result = urlparse(uri)
credential, machine = result.netloc.split('@')
username, password = credential.split(':')
host, port = machine.split(':')
path = result.path

print(prefix, 'SCHEME=', result.scheme)
print(prefix, 'USERNAME=', username)
print(prefix, 'PASSWORD=', password)
print(prefix, 'HOST=', host)
print(prefix, 'PORT=', port)
print(prefix, 'PATH=', path)
print(prefix, 'QUERY=', result.query)
print(prefix, 'FRAGMENT=', result.fragment)

