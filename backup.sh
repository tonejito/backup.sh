#!/bin/bash -vx

#	https://dev.yorhel.nl/ncdu/man
#	http://www.brynosaurus.com/cachedir/spec.html
#	https://www.gnu.org/software/tar/manual/html_section/tar_49.html

# Operate on filesystem root
cd /

# Create CACHEDIR.TAG in /tmp
printf "Signature: 8a477f597d28d172789f06886806bc55" > /tmp/CACHEDIR.TAG

# Write one per line the directories to exclude, you might use `ncdu -x /` to check for them
cat > /.exclude << EOF
/opt/phpmyadmin/htdocs/.git
EOF

# Create a CACHEDIR.TAG in each of the /.exclude(d) directories
cat /.exclude | tr '\n' '\0' | xargs -0 -r -t -n 1 -I {} ln -v /tmp/CACHEDIR.TAG {}/

# Create a plain TAR backup with label, save the command log to a file
/bin/tar -vv \
  --create \
  --numeric-owner \
  --one-file-system \
  --check-links \
  --seek \
  --totals \
  --verify \
  --sparse \
  --preserve-order \
  --preserve-permissions \
  --exclude-caches \
  --exclude /"`hostname -f`*.tar" \
  --exclude /"`hostname -f`*.log" \
  --exclude-from /.exclude \
  --label "`hostname -f`_`date '+%F'`" \
  --file /"`hostname -f`_`date '+%F'`.tar" \
  / \
&> /"`hostname -f`_`date '+%F'`.log"
