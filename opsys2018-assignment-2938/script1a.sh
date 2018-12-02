#!/bin/bash

#This script takes a file containing links to websites and stores information about their source code updates



#This function tests if a line is empty or a comment
#returns:(0 if line is not empty/comment)&&(1 if the line is a comment or empty)
function line_is_valid () {
	if [[ $1 == \#* ]] ||  [[ -z $1 ]]
	then
		return 1
	else
	 	return 0
	fi	
}


#This function is used to initialize a url inside source.If the url doesnt exist in source.txt ,it is added 
# and the appropriate stdout is printed
#returns:(0 if the url was initialized)&&(1 if the url has already been initialized)
function init () {
	if ! grep -q "$1" source.txt
	then
		if curl -s "$1" > temp.txt 
		then
			md5="$(md5sum temp.txt | awk '{ print $1 }')"
			echo $md5 $1 >> source.txt
			echo "$1 INIT"
			rm temp.txt	
			return 0;
		else
			echo "$1 FAILED"
		
		fi
	fi
	return 1;
}


#This function is extracting a url and stores its md5hash to newHash,then it looks inside source for the previous hash and compares them.
#If they match,it does nothing.If they dont match,it means the site was updated,so  it prints the site and updates the hash inside source
#If url extraction fails,it prints an error message
function search_update() {
	
	if curl -s "$1" > temp.txt
	then
		newHash="$(md5sum temp.txt | awk '{ print $1 }')"
		prevHash="$(grep "$1" source.txt | awk '{ print $1 }')"
		if ! [ "$newHash" = "$prevHash" ]
		then
			echo $1
			sed -i "s/$prevHash/$newHash/" source.txt
		fi	
	else
		echo "$1 FAILED"
	fi
	rm temp.txt
}








#Making sure that source.txt exists
if ! [[ -r source.txt ]] 
then
	touch source.txt
fi


while read row; do
	if  line_is_valid $row 
	then
		if ! init $row 
		then
			search_update $row
		fi
	fi		
done < $1
