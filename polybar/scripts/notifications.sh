#!/usr/bin/env bash
echo $(rofication-status | sed -E 's/<[^>]+>//g')
