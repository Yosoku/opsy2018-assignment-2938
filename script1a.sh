#!/bin/bash


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
		echo "$1 INIT"
		
		curl -s $1 >> temp.txt && md5=`md5sum temp.txt | awk '{ print $1 }'`
		echo $md5 $1 >> source.txt
		rm temp.txt	
		return 0;
	fi
	return 1;
}





function search_update() {
	
	prevHash="$(grep "$1" source.txt | awk '{print $1}')"
	newHash=`curl -s $1 >> temp.txt && md5sum temp.txt | awk '{ print $1 }'`
	rm temp.txt
	
	if ! [ "$newHash" = "$prevHash" ]
	then
		echo $1
		sed -i "s/$prevHash/$newHash/" source.txt
	fi

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
