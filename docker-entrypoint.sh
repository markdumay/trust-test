#!/bin/sh

cat /message.txt
trap : TERM INT
(while true; do sleep infinity; done) & wait
