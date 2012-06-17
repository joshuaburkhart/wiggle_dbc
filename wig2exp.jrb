#Usage: jruby wig2exp.jrb <filename>
#Example: jruby wig2exp.jrb ~/Documents/methylation_data/cml/ESX000001749.wig > ~/Documents/methylation_data/cml/ESX000001749.wig.explicit

filename = ARGV[0]
File.open(filename,'r') do |file|
	chrm_label = "default"
	while line = file.gets
		if(line.match(/^track/))
			print line
		elsif(line.match(/^variableStep/))
			print line
			chrm_label = line.match(/chrom=(.*?)[' ']/)[1]
		elsif(line.match(/^[0-9]/))
			print "#{chrm_label}-#{line}"
		end
	end
end

