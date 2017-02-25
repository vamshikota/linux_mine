import os
import sys
import subprocess as sp
import platform
import multiprocessing



## Server Details

print "Server Information :"
print "=" * 20

os=platform.dist()
print '[--]', "OS :","\t\t\t", os[0], os[1]

cpu_count = multiprocessing.cpu_count()
print '[--]',"Processors :","\t",cpu_count

