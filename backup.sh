#!/bin/bash -vx

#       https://dev.yorhel.nl/ncdu/man
#       http://www.brynosaurus.com/cachedir/spec.html
#       https://www.gnu.org/software/tar/manual/html_section/tar_49.html
#	https://gist.github.com/tonejito/1349e8b740423d808f15

PRINTF=printf
CAT=cat
TR=tr
XARGS=xargs
CP=cp
HOSTNAME=hostname
DATE=date
TAR=tar
TEE=tee
MD5SUM=md5sum
SHA1SUM=sha1sum
SHA256SUM=sha256sum

# Operate on filesystem root
cd /

# Create CACHEDIR.TAG in /tmp
$PRINTF "Signature: 8a477f597d28d172789f06886806bc55" > /tmp/CACHEDIR.TAG

# Write one per line the directories to exclude, you might use `ncdu -x /` to check for them
$CAT > /.exclude << EOF
/dev/
/proc/
/sys/
/run/
/srv/
EOF

# Create a CACHEDIR.TAG in each of the /.exclude(d) directories
$CAT /.exclude | $TR '\n' '\0' | $XARGS -0 -r -t -n 1 -I {} $CP -v /tmp/CACHEDIR.TAG {}/

BACKUP="`$HOSTNAME -f`"
DATE="`$DATE '+%F'`"
PREFIX=/srv

# Create a plain TAR backup with label, save the command log to a file
$TAR -vv \
  --create \
  --numeric-owner \
  --one-file-system \
  --check-links \
  --seek \
  --totals \
  --verify \
  --sparse \
  --preserve-permissions \
  --exclude-caches \
  --exclude "${PREFIX}/${BACKUP}_*.tar" \
  --exclude "${PREFIX}/${BACKUP}_*.log" \
  --exclude-from /.exclude \
  --label "${BACKUP}_${DATE}" \
  --file "${PREFIX}/${BACKUP}_${DATE}.tar" \
  / \
2>&1 | $TEE "${PREFIX}/${BACKUP}_${DATE}.log"

pushd .
cd $PREFIX
$MD5SUM "${BACKUP}_${DATE}.tar" | $TEE "${BACKUP}_${DATE}.md5"
$SHA1SUM "${BACKUP}_${DATE}.tar" | $TEE "${BACKUP}_${DATE}.sha1"
$SHA256SUM "${BACKUP}_${DATE}.tar" | $TEE "${BACKUP}_${DATE}.sha256"
popd

