#!/usr/bin/env bash
input_dir=$1; #Should be an absolute path
output_dir=$2; #Should be an absolute path

if ! [ -d "${output_dir}" ] ; then
	mkdir "${output_dir}";
fi

cd "${input_dir}";

# All directories are also files in Linux. Need directory check
files=(*); #List of all the files

for file in "${files[@]}"
do
	if [ -d "${file}" ] ; then
		zip -qq -r "${output_dir}/${file}" "${file}";
	fi
done

echo "Done!";

