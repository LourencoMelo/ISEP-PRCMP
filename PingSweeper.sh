#!/bin/bash

if [ $# -ne 1 ]
then
	read -p "Nenhum parametro inserido. Por favor insira o nome do ficheiro - " fich
else
	fich=$1
fi

if [ ! -f $fich ]
then
	i=0
	while [ $i -lt 3 ]
	do
		rest=$((3-$i))
		read -p "Parametro inserido não é um ficheiro. Tente outra vez ($rest tentativa(s) restantes) -  " fich
		if [ -f $fich ]
		then
			break
		else
			i=$(($i+1))
		fi
	done
fi

if [ "$i" = "3" ]
then
	echo "Tentativas excedidas. O programa irá encerrar."
else
	rm -f reachability_test.txt
	touch reachability_test.txt
	ATIVOS=()
	INATIVOS=()
	INVALIDOS=()
	nativos=0
	ninativos=0
	ninvalidos=0
	for linha in `cat $fich`
	do
		n=`echo $linha | tr '.' 'a' | grep -o 'a' | wc -l`
		if [ "$n" = "3" ]
		then
			next=0
			for var in {1..4}
			do
				oct=`echo $linha | cut -d '.' -f$var`
				if [ "$oct" -gt "255" ]
				then
					next=1
					break
				fi
				if [ "$oct" -lt "0" ]
				then
					next=1
					break
				fi
			done
			if [ "$next" = "1" ]
			then
				INVALIDOS+=" $linha"
				ninvalidos=$(($ninvalidos+1))
			else
				conectou=`ping -c 1 $linha | grep -c "100% packet loss"`
				if [ "$conectou" = "0" ]
				then
					ATIVOS+=" $linha"
					nativos=$(($nativos+1))
				else
					INATIVOS+=" $linha"
					ninativos=$(($ninativos+1))
				fi
			fi
		else
			INVALIDOS+=" $linha"
			ninvalidos=$(($ninvalidos+1))
		fi
	done
	echo "Número de endereços ativos - $nativos" >> reachability_test.txt
	echo $ATIVOS >> reachability_test.txt
	echo "Número de endereços inativos - $ninativos" >> reachability_test.txt
	echo $INATIVOS >> reachability_test.txt
	echo "Número de endereços invalidos - $ninvalidos" >> reachability_test.txt
	echo $INVALIDOS >> reachability_test.txt
fi
