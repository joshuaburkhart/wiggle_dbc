wiggle_dbc
==========

A tool that finds density based clusters in wiggle files.


Custom Software & Analysis

I have developed a methylation data processing pipeline capable of reformatting, merging, filtering, and clustering in such a way that meaningful information is produced and is visualizable with current software solutions used by bioinformaticians.

Though all of datasets from PubMed used this project reside in the same file format, some of the data is missing. One of the .wig files may specify a value for chromosomal coordinate "2" while another .wig file has values for chromosomal coordinates "1" and "3" but not "2". In an initial assay using prototype filtering software, I have concluded that most of the chromosomal coordinates are perfectly conserved among all files. This remaining data should be enough to yield interesting and meaningful results. For this reason I will not attempt to replace missing values, a common practice in datamining, instead filtering and dropping them.

A brief description of each component in the pipeline is below.

An explicit file format was developed that replaces the standard .wig 'chromosomal coordinate' with an identifier that specifies both chromosome and coordinate. This allows a value's exact location in the genome to be known by reading a single line of the file and reduces the effort required in building software that conducts further analysis. The explicitly formatted .wig files should be appended with '.wig.explicit' or '.wig.exp' following their file names to indicate they are different from standard .wig files though contain all the information found in .wig files. The program that converts .wig files to .wig.explicit files is named 'wig2exp.jrb'.

A program, 'merge2exp.jrb', was developed to merge several .wig.explicit files into a single .wig.explicit file. This is used when combining tracks from the same condition; I combined my leukemia tracks this way. Additionally, merge2exp.jrb conducts the dropping of unmatched data as previously described and leaves only those readings with 100% support.

Combined data from one condition is then filtered through a separate dataset from another condition in order to identify differences. A visualization of the output is seen in the fifth 'track' from the top in the below image. The top four tracks have been filtered by the last track. The program that conducts the filtering is named 'expfilter.jrb'.

Finally, a program named 'clstrwig.jrb' uses the DBSCAN algorithm to cluster the filtered results, forming groups based on density. Using domain knowledge (chromosomes are physically separate from one another), a multithreaded implementation was developed that takes advantage of the .wig file format to cluster chromosomes simultaneously. A visualization of the output is seen in the seventh 'track' from the top in the below image. Density based clusters from the fifth track have been identified.

It is the intent of this methylation data processing pipeline that the groupings be used to better identify regions of differential H3K27 methylation.

Interpreting results

Because each value in the explicit data format is accompanied by both a chromosome and a coordinate it is possible to convert discoveries back to .wig format, making them viewable with tools like IGV. Both the filtering and clustering programs described above produce .wig files as output. Aside from confirmation of findings, visualization of the data allows mapping back to the human genome and can help to indicate candidate genes that could be used for diagnosis or prognosis prediction or to inform models of the leukemogenesis pathway.

