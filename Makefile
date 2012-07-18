LAUNCHER_URL=http://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar
SERVER_URL=http://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
CLIENT_URL=http://s3.amazonaws.com/MinecraftDownload/minecraft.jar
TMP_LAUNCHER=tmp_launcher
TMP_CLIENT=tmp_client
TMP_SERVER=tmp_server
SSL_ALIAS=login.minecraft.net
# must have equal length to
#      .minecraft.net
DOMAIN=.mc.4rt.org
# (foo.mc.4rt.org)
SSL_CN="*.mc.4rt.org"

.PHONY: import_java_keystore cleanup_java_keystore all

all: minecraft_launcher.jar minecraft_server.jar minecraft.jar www/MinecraftResources www/MinecraftDownload ssl/java.crt
	touch userdb.txt
	chmod 777 userdb.txt
	chmod -R 777 www/MinecraftSkins

import_java_keystore: ssl/java.crt
	sudo keytool -import -alias ${SSL_ALIAS} -file $< -keystore $$JRE_HOME/lib/security/cacerts -storepass changeit -noprompt

cleanup_java_keystore:
	sudo keytool -delete -alias ${SSL_ALIAS} -keystore $$JRE_HOME/lib/security/cacerts -storepass changeit

minecraft.jar: load/minecraft.jar
	rm -rf "${TMP_CLIENT}"
	mkdir ${TMP_CLIENT}
	cd ${TMP_CLIENT} ; fastjar xf ../$<
	# Resources
	perl -i -pe 's/s3\.amazonaws\.com/awsfo${DOMAIN}/' ${TMP_CLIENT}/ck.class
	# Skins
	perl -i -pe 's/s3\.amazonaws\.com/awsfo${DOMAIN}/' ${TMP_CLIENT}/rv.class
	perl -i -pe 's/s3\.amazonaws\.com/awsfo${DOMAIN}/' ${TMP_CLIENT}/vq.class
	# Keepalive
	perl -i -pe 's/session\.minecraft\.net/sessionfoo${DOMAIN}/' ${TMP_CLIENT}/adl.class
	# Serverjoin
	perl -i -pe 's/https:\/\/login\.minecraft\.net/http:\/\/loginfooo${DOMAIN}/' ${TMP_CLIENT}/hp.class
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: ck.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_CLIENT}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: adl.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_CLIENT}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: hp.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_CLIENT}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: rv.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_CLIENT}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: vq.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_CLIENT}/META-INF/MANIFEST.MF
	rm ${TMP_CLIENT}/META-INF/CODESIGN.RSA
	rm ${TMP_CLIENT}/META-INF/CODESIGN.SF
	cd ${TMP_CLIENT} ; fastjar cf ../$@ .

minecraft_launcher.jar: load/minecraft_launcher.jar ssl/minecraft.key
	rm -rf "${TMP_LAUNCHER}"
	mkdir ${TMP_LAUNCHER}
	cd ${TMP_LAUNCHER} ; fastjar xf ../$<
	cp ssl/minecraft.key ${TMP_LAUNCHER}/net/minecraft/minecraft.key
	perl -i -pe 's/login\.minecraft\.net/loginfoo${DOMAIN}/' ${TMP_LAUNCHER}/net/minecraft/LauncherFrame.class
	perl -i -pe 's/www\.minecraft\.net/wwwfoo${DOMAIN}/' ${TMP_LAUNCHER}/net/minecraft/LoginForm\$$10.class
	perl -i -pe 's/s3\.amazonaws\.com/awsfo${DOMAIN}/' ${TMP_LAUNCHER}/net/minecraft/GameUpdater.class
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/minecraft.key\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_LAUNCHER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/LauncherFrame.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_LAUNCHER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/LoginForm\$$10.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_LAUNCHER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/GameUpdater.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_LAUNCHER}/META-INF/MANIFEST.MF
	rm ${TMP_LAUNCHER}/META-INF/MOJANG_C.DSA
	rm ${TMP_LAUNCHER}/META-INF/MOJANG_C.SF
	cd ${TMP_LAUNCHER} ; fastjar cf ../$@ .
	cd www ; test -h $@ || ln -s ../$@

minecraft_server.jar: load/minecraft_server.jar
	rm -rf "${TMP_SERVER}"
	mkdir ${TMP_SERVER}
	cd ${TMP_SERVER} ; fastjar xf ../$<
	perl -i -pe 's/session\.minecraft\.net/sessionfoo${DOMAIN}/' ${TMP_SERVER}/fl.class
	cd ${TMP_SERVER} ; fastjar cf ../$@ .
	cd www ; test -h $@ || ln -s ../$@

ssl/serverkey.pem:
	openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout $@ -out $@ -subj "/CN=${SSL_CN}/countryName=US/stateOrProvinceName=CA/organizationName=Minecraft"
	echo "you may copy $@ to /etc/lighttpd/certs/login.minecraft.net.pem"

ssl/java.crt: ssl/serverkey.pem
	openssl x509 -outform der -in $< -out $@
	cd www ; test -h java.crt || ln -s ../$@

ssl/minecraft.key: ssl/serverkey.pem
	openssl rsa -outform der -in $< -pubout -out $@

load/minecraft_launcher.jar:
	wget -O $@ ${LAUNCHER_URL}

load/minecraft_server.jar:
	wget -O $@ ${SERVER_URL}

load/minecraft.jar:
	wget -O $@ ${CLIENT_URL}

load/MinecraftResources:
	mkdir -p $@
	cd $@ ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*\/)<\/Key>/g) { print "$$1\n" }' | while read line ; do mkdir -p "$$line" ; done
	# just to be sure - some dir's are missing...
	cd $@ ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*[^\/])<\/Key>/g) { print "$$1\n" }' | while read line ; do mkdir -p $$(dirname "$$line") ; done
	# fetch the resources
	cd $@ ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*[^\/])<\/Key>/g) { print "$$1\n" }' | while read line ; do wget -c -O "$$line" "http://s3.amazonaws.com/MinecraftResources/$$line" ; done

load/MinecraftDownload:
	mkdir -p $@
	cd $@ ; curl -s "http://s3.amazonaws.com/MinecraftDownload/" | perl -ne 'while (m/<Key>([^<\/]*)<\/Key>/g) { print "$$1\n" }' | while read line ; do wget -c -O "$$line" "http://s3.amazonaws.com/MinecraftDownload/$$line" ; done

www/MinecraftResources: load/MinecraftResources
	rm -rf $@
	cp -r $< $@
	cp www/index_aws.php $@/index.php

www/MinecraftDownload: load/MinecraftDownload minecraft.jar
	rm -rf $@
	cp -r $< $@
	cd $@ ; test -h resources || ln -s ../MinecraftResources resources
	cp minecraft.jar $@
	cp www/index_aws.php $@/index.php

clean:
	rm -f ./ssl/*
	#rm -rf ./load/*
	rm -rf "${TMP_CLIENT}"
	rm -rf "${TMP_LAUNCHER}"
	rm -f minecraft_launcher.jar
	rm -f minecraft.jar
	rm -rf "www/MinecraftDownload"
	rm -rf "www/MinecraftResources"
	rm -f www/java.crt
