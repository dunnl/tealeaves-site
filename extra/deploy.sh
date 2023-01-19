#!/bin/sh

rsync -ave ssh _site/ lawrence@tealeaves:staging
ssh lawrence@tealeaves "cd staging; git add -A; git commit -m \"Automated commit\""
