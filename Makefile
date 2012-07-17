LAUNCHER_URL=https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar
SERVER_URL=https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
TMP_FOLDER=tmp
SSL_ALIAS=login.minecraft.net
# must have equal length to
#      .minecraft.net
DOMAIN=.mc.4rt.org
# (foo.mc.4rt.org)
SSL_CN="*.mc.4rt.org"

.PHONY: resources downloads import_java_keystore cleanup_java_keystore all

all: minecraft_launcher.jar

import_java_keystore: ssl/java.crt
	sudo keytool -import -alias ${SSL_ALIAS} -file $< -keystore $$JRE_HOME/lib/security/cacerts -storepass changeit -noprompt

cleanup_java_keystore:
	sudo keytool -delete -alias ${SSL_ALIAS} -keystore $$JRE_HOME/lib/security/cacerts -storepass changeit

minecraft_launcher.jar: load/minecraft_launcher.jar ssl/minecraft.key
	rm -rf "${TMP_FOLDER}"
	mkdir ${TMP_FOLDER}
	cd ${TMP_FOLDER} ; fastjar xf ../$<
	cp ssl/minecraft.key ${TMP_FOLDER}/net/minecraft/minecraft.key
	perl -i -pe 's/login\.minecraft\.net/loginfoo${DOMAIN}/' ${TMP_FOLDER}/net/minecraft/LauncherFrame.class
	perl -i -pe 's/www\.minecraft\.net/wwwfoo${DOMAIN}/' ${TMP_FOLDER}/net/minecraft/LoginForm\$$10.class
	perl -i -pe 's/s3\.amazonaws\.com/awsfo${DOMAIN}/' ${TMP_FOLDER}/net/minecraft/GameUpdater.class
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/minecraft.key\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_FOLDER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/LauncherFrame.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_FOLDER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/LoginForm\$$10.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_FOLDER}/META-INF/MANIFEST.MF
	perl -i -e 'undef $$/; $$_=<>; s#\r\nName: net/minecraft/GameUpdater.class\r\nSHA1-Digest: .*\r\n##g; print' ${TMP_FOLDER}/META-INF/MANIFEST.MF
	rm ${TMP_FOLDER}/META-INF/MOJANG_C.DSA
	rm ${TMP_FOLDER}/META-INF/MOJANG_C.SF
	cd ${TMP_FOLDER} ; fastjar cf ../$@ .

ssl/serverkey.pem:
	openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout $@ -out $@ -subj "/CN=${SSL_CN}/countryName=US/stateOrProvinceName=CA/organizationName=Minecraft"
	echo "you may copy $@ to /etc/lighttpd/certs/login.minecraft.net.pem"

ssl/java.crt: ssl/serverkey.pem
	openssl x509 -outform der -in $< -out $@

ssl/minecraft.key: ssl/serverkey.pem
	openssl rsa -outform der -in $< -pubout -out $@

load/minecraft_launcher.jar:
	wget -O $@ ${LAUNCHER_URL}

load/minecraft_server.jar:
	wget -O $@ ${SERVER_URL}

resources:
	mkdir -p www/MinecraftDownload
	mkdir -p www/MinecraftResources
	cd www/MinecraftDownload ; test -h resources || ln -s ../MinecraftResources resources
	cd www/MinecraftResources ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*\/)<\/Key>/g) { print "$$1\n" }' | while read line ; do mkdir -p "$$line" ; done
	# just to be sure - some dir's are missing...
	cd www/MinecraftResources ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*[^\/])<\/Key>/g) { print "$$1\n" }' | while read line ; do mkdir -p $$(dirname "$$line") ; done
	cd www/MinecraftResources ; curl -s "http://s3.amazonaws.com/MinecraftResources/" | perl -ne 'while (m/<Key>([^<]*[^\/])<\/Key>/g) { print "$$1\n" }' | while read line ; do wget -c -O "$$line" "http://s3.amazonaws.com/MinecraftResources/$$line" ; done

downloads:
	mkdir -p www/MinecraftDownload
	cd www/MinecraftDownload ; curl -s "http://s3.amazonaws.com/MinecraftDownload/" | perl -ne 'while (m/<Key>([^<\/]*)<\/Key>/g) { print "$$1\n" }' | while read line ; do wget -c -O "$$line" "http://s3.amazonaws.com/MinecraftDownload/$$line" ; done

clean:
	rm -f ./ssl/*
	rm -rf ./load/*
	rm -rf ./tmp/
	rm -f minecraft_launcher.jar
