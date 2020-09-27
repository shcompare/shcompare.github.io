#!/bin/bash

#
# programming_languages.sh
#

set -e
#C
apt-get install -yq gcc
apt show gcc 2>/dev/null | grep Installed-Size
#Installed-Size: 51.2 kB
# shellcheck disable=SC2028
echo "#include <stdio.h>

int main(int argc, char *argv[]) {
	printf(\"Hello %s.\\n\", argv[1]);
}" > HelloC.c
gcc -o HelloC HelloC.c

#rust
apt-get install -yq rustc
for P in rustc cargo gdb gdbserver libbabeltrace1 libc6-dbg libdw1 libhttp-parser2.7.1 libssh2-1 libstd-rust-1.43 libstd-rust-dev rust-gdb ; do
	apt show "$P" 2>/dev/null | grep Installed-Size
done
#321 MB
echo "use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!(\"Hello {}.\", &args[1]);
}" >  HelloRust.rs 
rustc HelloRust.rs

#Java
apt install -yq openjdk-11-jdk-headless
apt show openjdk-11-jre-headless 2>/dev/null | grep Installed-Size
#Installed-Size: 166 MB
du -sh /usr/lib/jvm
#342M	/usr/lib/jvm
echo "public class HelloJava {
	public static void main(String[] args) {
		System.out.println(\"Hello \" + args[0] + \".\");
	}
}" > HelloJava.java
javac HelloJava.java

#Graal
D="$(find /opt -maxdepth 1 -type d -name 'graalvm*' | head -n 1)"
if ! [ -d "$D" ] ; then
	(
	cd /opt
	wget 'https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.2.0/graalvm-ce-java11-linux-amd64-20.2.0.tar.gz'
	rm graalvm-*.tar.gz
	./graalvm-*/bin/gu install native-image
	)
	D="$(find /opt -maxdepth 1 -type d -name 'graalvm*' | head -n 1)"
fi
du -sh /usr/lib/jvm
#342M	/usr/lib/jvm
du -sh /opt/graalvm-ce-java11-20.2.0
#1.1G	/opt/graalvm-ce-java11-20.2.0
< HelloJava.java perl -pe 's/HelloJava/HelloGraal/g' > HelloGraal.java
javac HelloGraal.java
"$D/bin/native-image" -cp . HelloGraal HelloGraal --initialize-at-build-time

apt install -yq time
/usr/bin/time -v ./HelloC WorldC 2>&1 | grep -P 'User time|Maximum resident|Hello'
/usr/bin/time -v ./HelloRust WorldR 2>&1 | grep -P 'User time|Maximum resident|Hello'
/usr/bin/time -v java -cp . HelloJava WorldJ 2>&1 | grep -P 'User time|Maximum resident|Hello'
/usr/bin/time -v ./HelloGraal WorldG 2>&1 | grep -P 'User time|Maximum resident|Hello'
for T in O B C R J G ; do
	echo "$T 99"
	/usr/bin/time -v bash ~/scripts/XU4/java_vs_rust_test_helper.sh $T 2>&1 | grep -P 'User time|Maximum resident'
done
