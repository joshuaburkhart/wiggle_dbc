#Usage: jruby merge2exp.jrb <reference filename> <auxillary filename 1> <auxillary filename 2>
#Example: jruby merge2exp.jrb ESX0000001760.wig ESX0000001748.wig ESX0000003301.wig

merge_handle = File.open('merged.wig.exp','w')

ref_filename = ARGV[0]
merge_handle.print "\t#{ref_filename}\t"

aux_files = Array.new
aux_l_buf = Array.new

(1..ARGV.length - 1).each do |i|
	merge_handle.print "#{ARGV[i]}\t"
	aux_files << File.new(ARGV[i])
	aux_l_buf << "track"
end

merge_handle.puts

def valid(line,last,chrm,limit)
	within_limit = false 
	if(line.match(/^#{chrm}-.*[' '].*$/))
		line_pos = line.match(/^#{chrm}-(.*)[' '].*$/)[1]
		within_limit = (Integer(line_pos) <= Integer(limit))
	elsif(line.match(/^track/))
		within_limit = true
	elsif(line.match(/^variableStep/))
		within_limit = true
	elsif(last != chrm)
		within_limit = true
	end
	return within_limit
end

ref_chrm = "default"
last_ref = "default"
ref_start = -1
ref_label = "no-label"

File.open(ref_filename,'r') do |ref_file|
	while ref_line = ref_file.gets
		values = Array.new

		if(ref_line.match(/^track/))
			#print ref_line
		elsif(ref_line.match(/^variableStep/))
			#print ref_line
		elsif(ref_line.match(/^chr.*?-.*[' '].*$/))
			last_ref = ref_chrm
			ref_chrm = ref_line.match(/^(chr.*?)-.*$/)[1]
			ref_start = ref_line.match(/^#{ref_chrm}-(.*)[' '].*$/)[1]
			ref_label = "#{ref_chrm}-#{ref_start}"
			#puts "trying to match #{ref_label}"
			values << ref_line.match(/^#{ref_label}[' '](.*)$/)[1]
			aux_files.each_index do |i|
				#puts "comparing to #{aux_l_buf[i]}"
				while((cur_line = aux_l_buf[i]) && (valid(cur_line,last_ref,ref_chrm,ref_start)))
					if(cur_line.match(/^#{ref_label}[' '].*?$/))
						#puts "* matched with #{cur_line}"
						values << cur_line.match(/^#{ref_label}[' '](.*)$/)[1]
						break
					end
					aux_l_buf[i] = aux_files[i].gets
					#puts "now comparing to #{aux_l_buf[i]}"
				end
			end

			if(values.length == (aux_files.length + 1))
				#print "outputting #{ref_label}"
				merge_handle.print "#{ref_label}\t"
				values.each do |i|
					#print " #{i}"
					merge_handle.print "#{i}\t"
				end
				#puts
				merge_handle.puts
			end
		end		
	end
end

merge_handle.close

aux_files.each do |aux_file|
	aux_file.close
end

