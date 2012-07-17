#!/bin/bash

#echo -e "Content-type: application/xml\n"

cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Name>MinecraftResources</Name>
<Prefix></Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated>
EOF

IFS='
'
for line in `find *` ; do
mymd5="d41d8cd98f00b204e9800998ecf8427e"
test -d "$line" || mymd5=`md5sum "$line" | sed -e 's/ .*$//'`
filesize=`wc "$line" 2>/dev/null | awk '{print $3}'`
cat <<EOF
<Contents>
<Key>$line</Key>
<LastModified>`date -d "1970-01-01 + $(stat -c '%Z' "$line" ) secs" '+%FT%T.000Z'`</LastModified>
<ETag>&quot;$mymd5&quot;</ETag>
<Size>$filesize</Size>
<StorageClass>STANDARD</StorageClass>
</Contents>
EOF
done

echo "</ListBucketResult>"
