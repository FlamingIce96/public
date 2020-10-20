#!/bin/bash

####################################################################################################
# IOS - Operacni systemy                                                                           #
# Projekt I - dirgraph                                                                             #
#                                                                                                  #
# Autor: Nicol Castillo, xcasti00                                                                  #
# Datum: 31. 03. 2030                                                                              #
# Verze: 4											   #
#												   #
# Skenuje adresar zadany ve forme argumentu, pokdu neni zadany, tak se skenuje aktualni		   #
# Vypise se histogram a informace o adresarich a jejich obsahu					   #
# Jestli je skript spusteny s prepinacem -i, adresare a soubory budou ignorovany podle toho,	   #
# zda se shoduji se zadanym regularnim vyrazem  						   #
# Uziti: dirgraph [-i FILE_ERE] [-n] [DIR]							   #
# zadani jsem pochopila tak, ze pocitam s tim, ze						   #
#			uzivatel bude chtit ignorovat maximalne jednu vec			   #
#			bude uzivatel zadavat argumenty stale ve stejnem poradi			   #
# pro tento skript take predpokladam, ze v nazvech souboru se nevyskytuji mezery		   #
####################################################################################################


####################################################################################################
##### # promenne

DIR=""
ROOT_DIR="$PWD"
IGNORE=""
DO_NORMALIZATION=0

b=0; k=0; kk=0; kkk=0; m=0; mm=0; mmm=0; gl=0; gh=0
DirCount=0; FileCount=0

terminal_limit=67
#    "|  |<100| |KiB:| |" + "| |"na prave strane terminalu;
# 80   -2  -4  -1 -4  -1      -1 = 80 - 13 = 67

longestIs=0

POSIXLY_CORRECT=1
ORIGINAL_IFS=$IFS
IFS='
'

####################################################################################################
##### # case urcujici chybovou hlasku
##### # vstup: cislo chybove hlasky

error(){
	case $1 in
		"1" )
			echo "INVALID INPUT: Too many arguments" >&2
			exit 1;;
		"2" )
			echo "INVALID INPUT: Invalid argument option" >&2
			exit 1;;
		"3" )
			echo "INVALID INPUT: Missing argument" >&2
			exit 1;;
		"4" )
			echo "INVALID INPUT: Path does not exist" >&2
			exit 1;;
		"5" )
			echo "INVALID INPUT: You can not ignore this" >&2
			exit 1;;
	esac
}


####################################################################################################
##### # kontrolujeme zda se vypisuje na terminal

if [ -t 1 ]; then
	terminal_limit=$(($(tput cols)-13))
	fi


####################################################################################################
##### # overuje zda jsou na vstupu validni argumenty

while getopts ":i:n" opt; do
	case $opt in
		i )
			IGNORE="$OPTARG";;
		n )
			DO_NORMALIZATION=1;;
		\? )
			error "2";;
		: )
			error "3";;
	esac
done


####################################################################################################
##### # nastaveni ROOT_DIR
##### # vstup: argumenty pri spusteni

case "$#" in
	0 )
		DIR="$PWD";;
	1 )
		if [[ $1 != "-n" ]]; then
			DIR="$1"
			ROOT_DIR+="/$DIR"		
			fi
		;;
	2 )
		if [[ $1 = "-n" ]]; then
			DIR="$2"
			ROOT_DIR+="/$DIR"
			fi
		;;
	3 )
		if [[ $3 != "-n" ]]; then
			DIR="$3"
			ROOT_DIR+="/$DIR"
			fi
		;;
	4 )
		DIR="$4"
		ROOT_DIR+="/$DIR"		
		;;

	* )
		error "1";;
esac


####################################################################################################
##### # overujeme zda se jedna o validni vstupni adresar

if [ -d $ROOT_DIR ]; then
    cd "$ROOT_DIR"
else 
    error "4"
	fi


####################################################################################################
##### # overujeme zda uzivatel nechce ignorovat vstupni adresar

if [ "$IGNORE" = "$(basename $ROOT_DIR)" ]; then
    error "5"
	fi


####################################################################################################
##### # POCITANI PODLE VELIKOSTI SOUBORU
##### # vstup: velikost souboru

if_size(){

	((FileCount++))
	
		#	SIZE je mensi nez 100 B (zvysi b o jedna)
	if [[ $1 -lt 100 ]]; then
		b=$(($b + 1))
		return
		fi
	
		#	SIZE je mensi nez 1 KiB (zvysi k o jedna)
	if [[ $1 -lt 1024 ]]; then
			k=$(($k + 1))
		return
		fi

		#	SIZE je mensi 10 KiB (zvysi kk o jedna)
	if [[ $1 -lt 10240 ]]; then
		kk=$(($kk + 1))	
		return
		fi

		#	SIZE je mensi 100 KiB (zvysi kkk o jedna)
 	if [[ $1 -lt 102400 ]]; then
		kkk=$(($kkk + 1))
		return
		fi
	
		#	SIZE je mensi 1 MiB (zvysi m o jedna)
	if [[ $1 -lt 1048576 ]]; then
		m=$(($m + 1))
		return
		fi

		#	SIZE je mensi 10 MiB (zvysi mm o jedna)
	if [[ $1 -lt 10485760 ]]; then
		mm=$(($mm + 1))
		return
		fi

		#	SIZE je vetsi rovna 100 MiB (zvysi mmm o jedna)
	if [[ $1 -lt 104857600 ]]; then
		mmm=$(($mmm + 1))
		return
		fi

		#	SIZE je mensi 1 GiB (zvysi gl o jedna)
	if [[ $1 -lt 1073741824 ]]; then
		gl=$(($gl + 1))
		return
		fi

		#	SIZE je vetsi rovna 1 GiB (zvysi gh o jedna)
	gh=$(($gh + 1))
}


####################################################################################################
##### # rekurzivni prohledavani adresaru
##### # vstup: R00T_DIR

recursive_search() {

		((DirCount++))

		for vstup in "$1"/* "$1"/.*[^.]*; do
		
			if [ "$IGNORE" ] ; then
				tmpFN=$(printf %s "$(basename "$vstup")" | sed -r "s/$IGNORE//")
				[ "$tmpFN" != "$(basename "$vstup")" ]
				continue
				fi
			[[ -f "$vstup" ]] && if_size $(wc -c "$vstup" | awk '{print $1}')
			done
        
		for vstup in "$1"/* "$1"/.*[^.]*; do
			if [ "$IGNORE" ] ; then
				tmpDN=$(printf %s "$(basename "$vstup")" | sed -r "s/$IGNORE//")
				[ "$tmpDN" != "$(basename "$vstup")" ]
				continue
				fi
			[[ -d "$vstup" ]] && recursive_search "$vstup"
			done
}


####################################################################################################
##### # vyhledani nejdelsiho radku
##### # vstup: terminal_limit

longestCheck(){
	local_Max=$1

	if [[ local_Max -lt $b ]]; then
		local_Max=$b
		fi

	if [[ local_Max -lt $k ]]; then
		local_Max=$k
		fi

	if [[ local_Max -lt $kk ]]; then
		local_Max=$kk
		fi

	if [[ local_Max -lt $kkk ]]; then
		local_Max=$kkk
		fi

	if [[ local_Max -lt $m ]]; then
		local_Max=$m
		fi

	if [[ local_Max -lt $mm ]]; then
		local_Max=$mm
		fi

	if [[ local_Max -lt $mmm ]]; then
		local_Max=$mmm
		fi

	if [[ local_Max -lt $gl ]]; then
		local_Max=$gl
		fi

	if [[ local_Max -lt $gh ]]; then
		local_Max=$gh
		fi
		
	longestIs=$local_Max
}


####################################################################################################
##### # normalizovani velikosti
##### # vstup: promenna konkretni velikosti souboru

print_normalized_count(){
	print=$( awk -v small="$1" -v big="$longestIs" -v cols="$terminal_limit" 'BEGIN {print int((small * cols) / big)}' )
	print_ordinary_count $print
}


####################################################################################################
##### # vytisteni hodnoty bez noralizace
##### # vstup: promenna konkretni velikosti souboru

print_ordinary_count(){
	counter=0	
	while [ $counter -lt $1	]; do
		echo -n "#"
		((counter++))
		done
	echo
}


####################################################################################################
##### # urcovani typu tisteni histogramu
##### # vstup:  promenna konkretni velikosti souboru

print_count(){

	if [[ $DO_NORMALIZATION -eq 1 ]]; then
		if [[ $longestIs -lt $terminal_limit ]]; then
			print_ordinary_count $1
			return
			fi
		print_normalized_count $1
		return
		fi

	print_ordinary_count $1
}


####################################################################################################
##### # SPUSTI REKURZIVNI PROHLEDAVANI
recursive_search $ROOT_DIR


####################################################################################################
##### # NASTAVENI NEJDELSIHO RADKU
longestCheck $terminal_limit


####################################################################################################
##### # VYPIS HODNOT
echo "Root directory: $DIR"
echo "Directories: $DirCount"
echo "All files: $FileCount"
echo "File size histogram:"

##### # VYPIS HISTOGRAMU
echo -n "  <100 B  : "; print_count $b
echo -n "  <1 KiB  : "; print_count $k
echo -n "  <10 KiB : "; print_count $kk
echo -n "  <100 KiB: "; print_count $kkk
echo -n "  <1 MiB  : "; print_count $m
echo -n "  <10 MiB : "; print_count $mm
echo -n "  <100 MiB: "; print_count $mmm
echo -n "  <1 GiB  : "; print_count $gl
echo -n "  >=1 GiB : "; print_count $gh

exit 0

##### Zde končí kód #################################################################################

