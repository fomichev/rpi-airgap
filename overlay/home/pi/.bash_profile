echo "<"
echo "$ backup-mount [/dev/sda] [/media] to mount external /dev/sda"
echo "$ backup-umount [/media] to cleanup when done"
echo "$ backup-cp [/dev/sdb] backup everything from /media to another location"
echo "$ gpg-enc [file] [...file] to gpg-encrypt files"
echo "$ gpg-dec [file] [...file] to gpg-decrypt files"
echo ">"

export PATH="${PATH}:/usr/local/bin:/usr/local/go/bin"
