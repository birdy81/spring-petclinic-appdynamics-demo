#!/bin/sh
# this command stops all spring petclinic processes executed with spring-boot:run
kill $(ps aux | awk '/[s]pring-petclinic/' | awk '{print $2}')
