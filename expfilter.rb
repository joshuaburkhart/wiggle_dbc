#Usage: jruby expfilter.jrb <file to be filtered> <filter file>
#Example: jruby expfilter.jrb merged.wig.explicit healthy.wig.explicit

MAX_VAL = 1.0 #value when filter is maximum
MIN_VAL = 0.0 #value when filter is minimum

# monkey patches

class MatchData
	def order
		a = self[1].split("\s")
		a.sort {|i,j| ("%f" % "#{i}").to_f <=> ("%f" % "#{j}").to_f}
	end
	def max
		"%f" % self.order.last
	end
	def min
		"%f" % self.order.first	
	end
end
class String
	def get_chromosome
		self.match(/^(chr.*?)-.*$/)[1]
	end
	def get_coordinate
		self.match(/^#{self.get_chromosome}-(.*?)['\s'].*$/)[1]
	end
	def get_value
		"%f" % self.match(/^#{self.get_chromosome}-#{self.get_coordinate}['\s'](.*?)['\s'].*?$/)[1]
	end
end 

def valid(line,last,chrm,limit)
	within_limit = false
	if(line.match(/^#{chrm}-.*$/))
		within_limit = (Integer(line.get_coordinate) <= Integer(limit))
	elsif(line.match(/^track/))
		within_limit = true
	elsif(line.match(/^variableStep/))
		within_limit = true
	elsif(last != chrm)
		within_limit = true
	end
	return within_limit
end

merged = File.open(ARGV[0])
filter = File.open(ARGV[1])

aux_l_buf = "track"
f_chrom = "default"
last_ref = "default"

while(filter_line = filter.gets)
	#print line if track or validation
	if(filter_line.match(/^track/))
		print filter_line
	elsif(filter_line.match(/^variableStep/))
		print filter_line
	elsif(filter_line.match(/^chr.*?-.*$/))
		#puts "found a dataline: #{filter_line}"	
		last_ref = f_chrom
		f_chrom = filter_line.get_chromosome
		f_coord = filter_line.get_coordinate
		f_label = "#{f_chrom}-#{f_coord}"
		while((cur_line = aux_l_buf) && (valid(cur_line,last_ref,f_chrom,f_coord)))
			if(cur_line.match(/^#{f_label}.*$/))
				#puts "matched f_label"
				m_values = cur_line.match(/^#{f_label}['\s'](.*)$/)
				#puts "filter_line: #{filter_line}"
				#puts "merged_line: #{cur_line}"
				#puts "m_values.max: #{m_values.max}"
				#puts "m_values.min: #{m_values.min}"
				f_value = filter_line.get_value
				#puts "f_value: #{f_value}"
				if(Float(m_values.max) < Float(f_value))
					puts "#{filter_line.get_coordinate} #{MAX_VAL}"
					#puts "m_values.max: #{m_values.max} < f_value: #{f_value}"
				elsif(Float(m_values.min) > Float(f_value))
					puts "#{filter_line.get_coordinate} #{MIN_VAL}"
					#puts "m_values.min: #{m_values.min} > f_value: #{f_value}"
				end 
				break
			end
			aux_l_buf = merged.gets

		end

	end
end

merged.close
filter.close

