#!/bin/bash

#
# programming_languages.sh
#

HELPER="programming_languages_helper.sh"

set -e
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR
if ! [ -f /usr/bin/time ] ; then
	apt-get install -yqq time
fi
log(){
	echo "{
\"language\": \"$1\",
\"Development kit (Bytes)\": \"$2\",
\"Runtime (Bytes)\": \"$3\",
\"Resident memory (Bytes)\": \"$4\",
\"99 resident memories (Bytes)\": \"$5\",
\"Compile time (Seconds)\": \"$6\",
\"Start time (Seconds)\": \"$7\",
\"99 start times (Seconds)\": \"$8\",
\"Test\":\"$9\"
},"
}
h2s(){
	T="$1"
	T="$(echo "$T" | perl -pe 's/s.*//g')"
	TH="0"
	if [[ "$T" =~ .*h.* ]] ; then
		TH="$(echo "$T" | perl -pe 's/h.*//g')"
		T="$(echo "$T" | perl -pe 's/.*h//g')"
	fi
	TM="0"
	if [[ "$T" =~ .*m.* ]] ; then
		TM="$(echo "$T" | perl -pe 's/m.*//g')"
		T="$(echo "$T" | perl -pe 's/.*m//g')"
	fi
	T="$(echo "$T+($TM*60)+($TH*60*60)" | bc)"
	echo "$T"
}
echo "{\"data\":["
TEST="Hello World"
#C
which gcc > /dev/null || apt-get install -yqq gcc
C2="$(apt show gcc 2>/dev/null | grep Installed-Size | perl -pe 's/.*: //g;s/.([0-9]) kB/${1}00/g')"
# shellcheck disable=SC2028
echo "#include <stdio.h>

int main(int argc, char *argv[]) {
	printf(\"Hello %s.\\n\", argv[1]);
}" > HelloC.c
C6="$( (time gcc -static -o HelloC HelloC.c) 2>&1 | grep real | perl -pe 's/.*\t//g;s/0m|s//g')"
C3="$(stat -c %s HelloC)"
C4="$(/usr/bin/time -v ./HelloC WorldC 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
C5="$(/usr/bin/time -v bash "$HELPER" C 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
C7="$(/usr/bin/time -v ./HelloC WorldC 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
C8="$(/usr/bin/time -v bash "$HELPER" C 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
log "C" "$C2" "$C3" "$C4" "$C5" "$C6" "$C7" "$C8" "$TEST"

#rust
which rustc > /dev/null || apt-get install -yqq rustc
R2="$(
for P in rustc cargo gdb gdbserver libbabeltrace1 libc6-dbg libdw1 libhttp-parser2.7.1 libssh2-1 libstd-rust-1.43 libstd-rust-dev rust-gdb ; do
	apt show "$P" 2>/dev/null | grep Installed-Size
done | perl -pe 's/.*: |,//g;
	s/\.([0-9]) kB/${1}000/g;
	s/^([^.]+) kB/${1}000/g;
	s/\.([0-9]) MB/${1}000000/g;
	s/^([^.]+) MB/${1}000000/g;
	s/\n/+/g'
)"
R2="$(echo "${R2}0" | bc)"
echo "use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!(\"Hello {}.\", &args[1]);
}" >  HelloRust.rs 
R6="$( (time rustc HelloRust.rs) 2>&1 | grep real | perl -pe 's/.*\t//g;s/0m|s//g')"
R3="$(stat -c %s HelloRust)"
R4="$(/usr/bin/time -v ./HelloRust WorldR 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
R5="$(/usr/bin/time -v bash "$HELPER" R 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
R7="$(/usr/bin/time -v ./HelloRust WorldR 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
R8="$(/usr/bin/time -v bash "$HELPER" R 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
log "Rust" "$R2" "$R3" "$R4" "$R5" "$R6" "$R7" "$R8" "$TEST"

#Java
which javac > /dev/null || apt-get install -yq openjdk-11-jdk-headless
J2="$(apt show openjdk-11-jre-headless 2>/dev/null | grep Installed-Size | perl -pe 's/.*: //g;s/^([^.]+) MB/${1}000000/g')"
J3="$(apt show openjdk-11-jdk-headless 2>/dev/null | grep Installed-Size | perl -pe 's/.*: //g;s/^([^.]+) MB/${1}000000/g')"
J2="$( echo "$J2+$J3" | bc)"
echo "public class HelloJava {
	public static void main(String[] args) {
		System.out.println(\"Hello \" + args[0] + \".\");
	}
}" > HelloJava.java
J6="$( (time javac HelloJava.java) 2>&1 | grep real | perl -pe 's/.*\t//g;s/0m|s//g')"
#J3="$(stat -c %s HelloJava.class)"
J4="$(/usr/bin/time -v java -cp . HelloJava WorldJ 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
J5="$(/usr/bin/time -v bash "$HELPER" J 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
J7="$(/usr/bin/time -v java -cp . HelloJava WorldJ 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
J8="$(/usr/bin/time -v bash "$HELPER" J 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
log "Java" "$J2" "$J3" "$J4" "$J5" "$J6" "$J7" "$J8" "$TEST"

#Jlink
JAVA="$(find /opt/ -maxdepth 1 -iname 'jdk*' | grep -P "15" | head -n 1)"
if ! [ -f "$JAVA" ] ; then
	wget -q "https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15%2B36/OpenJDK15U-jdk_$(uname -p)_linux_hotspot_15_36.tar.gz"
	tar -xf OpenJDK15U-jdk_*.tar.gz
	rm OpenJDK15U-jdk_*.tar.gz
	JAVA="$(find /opt/ -maxdepth 1 -iname 'jdk*' | grep -P "15" | head -n 1)"
fi
L2="$J2"
echo "package test;
public class HelloJlink {
	public static void main(String[] args) {
		System.out.println(\"Hello \" + args[0] + \".\");
	}
}" > HelloJlink.java
echo "module HelloJlink {
}" > module-info.java
mkdir jlinktest
L6="$( (time (
$JAVA/bin/javac -d jlinktest module-info.java
$JAVA/bin/javac -d jlinktest --module-path jlinktest HelloJlink.java
$JAVA/bin/jlink --module-path $JAVA/jmods:jlinktest --add-modules HelloJlink --output HelloJlink
) ) 2>&1 | grep real | perl -pe 's/.*\t//g;s/0m|s//g')"
L3="$(du -s HelloJlink | perl -pe 's/\t.*//g;s/\n/000/g')"
L4="$(/usr/bin/time -v ./HelloJlink/bin/java --module HelloJlink/test.HelloJlink WorldL 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
L5="$(/usr/bin/time -v bash "$HELPER" L 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
L7="$(/usr/bin/time -v ./HelloJlink/bin/java --module HelloJlink/test.HelloJlink WorldL WorldL 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
L8="$(/usr/bin/time -v bash "$HELPER" L 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
log "JLink" "$L2" "$L3" "$L4" "$L5" "$L6" "$L7" "$L8" "$TEST"

#Graal
D="$(find /opt -maxdepth 1 -type d -name 'graalvm*' | head -n 1)"
if ! [ -d "$D" ] ; then
	(
	cd /opt
	wget -q "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.2.0/graalvm-ce-java11-linux-$(uname -p)-20.2.0.tar.gz"
	tar -xf graalvm-*.tar.gz
	rm graalvm-*.tar.gz
	./graalvm-*/bin/gu install native-image > /dev/null
	)
	D="$(find /opt -maxdepth 1 -type d -name 'graalvm*' | head -n 1)"
fi
G2="$(du -s /opt/graalvm-ce-java11-20.2.0 | perl -pe 's/\t.*//g;s/\n/000/g')"
G2="$(echo "$G2+$J2" | bc)"
< HelloJava.java perl -pe 's/HelloJava/HelloGraal/g' > HelloGraal.java
javac HelloGraal.java
G6="$( (time "$D/bin/native-image" -cp . HelloGraal HelloGraal --initialize-at-build-time) 2>&1 | grep real | perl -pe 's/.*\t//g')"
G6="$(h2s "$G6")"
G3="$(stat -c %s HelloGraal)"
G4="$(/usr/bin/time -v ./HelloGraal WorldG 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
G5="$(/usr/bin/time -v bash "$HELPER" G 2>&1 | grep 'Maximum resident' | perl -pe 's/.* //g;s/\n/000/g')"
G7="$(/usr/bin/time -v ./HelloGraal WorldG 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
G8="$(/usr/bin/time -v bash "$HELPER" G 2>&1 | grep 'User time' | perl -pe 's/.* //g')"
log "Graal-native" "$G2" "$G3" "$G4" "$G5" "$G6" "$G7" "$G8" "$TEST"
echo "{}]}"
