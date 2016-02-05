#!/bin/bash -vx

cd /

 /bin/tar -vv \
  --create \
  --numeric-owner \
  --one-file-system \
  --preserve \
  --check-links \
  --seek \
  --totals \
  --verify \
  --sparse \
  --preserve-order \
  --preserve-permissions \
  --exclude-from /.exclude \
  --label "`hostname -f`_`date '+%F'`" \
  --file /"`hostname -f`_`date '+%F'`.tar" \
  / \
;
