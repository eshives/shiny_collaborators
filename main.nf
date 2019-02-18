#!/usr/bin/env nextflow

params.file_dir = 'datasci611/data/p2_abstracts/abs*.txt'
comparison_csv = file('college_list.csv')
combined_csv = file('data/combined.txt')

file_channel = Channel.fromPath( params.file_dir )

process getCollaborators {
	container 'rocker/tidyverse:3.5'
	publishDir 'data', mode: 'copy'
	
	input:
	file f from file_channel
	file comparison_csv
	
	output:
	file '*.csv' into collabs
	
	"""
	Rscript $baseDir/col.R $f $comparison_csv
	"""
}

process combine {
	container 'rocker/tidyverse:3.5'
	publishDir 'data', mode: 'copy'
	
	input:
	file i from collabs.collectFile(name: 'collabColleges.csv', newLine: true)

	output:
	file '*.txt' into out_txt
	
	"""
	cat $i > combined.txt
	"""
}

process topTenList{
	container 'rocker/tidyverse:3.5'
	publishDir '.', mode: 'copy'
	
	input:
	file i from out_txt
	
	output:
	file 'topten.csv' into top_ten
	
	"""
	Rscript $baseDir/top.R $i
	"""
}

process dockerpull{
	"""
	docker pull eshives/611project3
	"""
}




