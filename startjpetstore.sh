#!/bin/sh
nohup mvn cargo:run -P tomcat90 </dev/null >/dev/null 2>&1 &