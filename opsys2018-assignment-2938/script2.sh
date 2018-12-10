#! /bin/bash



#Function which clones a given repository
function gclone () {
	cd assignments 
	if git clone -q $1 &> /dev/null
	then		
		echo "$1 CLONING OK"
	else
		echo "$1 CLONING FAILED" >&2	
	fi
	cd - &> /dev/null


}

#Function which makes sure that structure of a repository is the desired one
function printdir(){
	
	dirs="$(find "$1"/* -name .git -prune -o -type d 2> /dev/null | wc -l)" 
	txts="$(find "$1"/* -name .git -prune -o -type f -iname "*.txt" 2> /dev/null | wc -l)" 
	all="$(find "$1"/* -name .git -prune -o -type f ! -iname "*.txt" 2> /dev/null | wc -l)"
	echo ${1/"./assignments/"/}:
	echo "Number of directories: $dirs"
	echo "Number of txt files: $txts "
	echo "Number of other files: $all"
	
	
	num="$(find $1 -maxdepth 1 ! -type d | wc -l)"
	name="$(find $1 -maxdepth 1  | grep "dataA.txt")"
	if ! [[ $dirs == 1 ]] 
	then
		echo "Directory structure is NOT OK" >&2
	else
		if [[ $num = 1 ]] && ! [ -z $name ]
		then		
			num="$(find "$1"/more -name "dataB.txt" -o -name "dataC.txt" | wc -l)"
			if [[ $num == 2 ]]
			then
				echo "Directory structure is OK"
			else
				echo "Directory structure is NOT OK" >&2
			fi
		else
			echo "Directory structure is NOT OK" >&2
		fi
	fi				
}



#if assignments hasnt been created then make it
if ! [ -e ./assignments ]
then	
	mkdir assignments
fi

#unzip
github="$(tar xzf $1 &> /dev/null)"
#myfiles is all .txt's in $1
myfiles="$(find $github -type f -iname "*.txt")"
#clone every file
for file in $myfiles
do
	var="$(grep "^[^#;]" $file)" #ignore comments,doesnt ignore random strings
	gclone $var
done
#repos is all the repos in assignments
repos="$(find ./assignments -maxdepth 1 -type d -iname "repo*")"

for repo in $repos
do
	printdir $repo
done




