#!/bin/bash
echo `date -u +%FT%TZ` > DEPLOYED_AT 
exec /sbin/my_init
