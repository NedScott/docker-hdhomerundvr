#!/bin/bash

# chfn workaround - Known issue within Dockers
ln -s -f /bin/true /usr/bin/chfn

cd /etc/apt/sources.list.d
echo "deb http://old-releases.ubuntu.com/ubuntu/ raring main restricted universe multiverse" >ia32-libs-raring.list
sudo dpkg --add-architecture i386
apt-get -q update
apt-get install -qy ia32-libs
rm /etc/apt/sources.list.d/ia32-libs-raring.list
apt-get -q update
apt-get install -qy gdebi-core wget

#download and install hdhomerun dvr engine
wget -q --output-document=/tmp/hdhomerun_record_linux http://download.silicondust.com/hdhomerun/hdhomerun_record_linux
cd /tmp
dd if=/tmp/hdhomerun_record_linux bs=4096 skip=1 2>/dev/null|tar -xz hdhomerun_record_x86
cp /tmp/hdhomerun_record_x86 /usr/bin/
chmod +x /usr/bin/hdhomerun_record_x86

# Add hdhomerun dvr to runit
mkdir -p /etc/service/hdhomerun_record
cat <<'EOT' > /etc/service/hdhomerun_record/run
#!/bin/bash
umask 000
# Fix permission if user is 999
if [ -d /hdhomerun ]; then
	if [ "$(stat -c "%u" /hdhomerun)" -eq "999" ]; then
		echo "Fixing HDHOMERUN Library permissions"
		chown -R 99:100 /hdhomerun
		chmod -R 777 /hdhomerun
	fi
fi
exec /usr/bin/hdhomerun_record_x86 start
EOT
chmod +x /etc/service/hdhomerun_record/run
