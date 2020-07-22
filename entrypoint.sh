#!/bin/bash
echo `date -u +%FT%TZ` > DEPLOYED_AT 
/sbin/my_init
