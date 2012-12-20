# script that generate time/space pacings from NSLog/CCLog output in xcode console log
o = Array.new
File.open(ARGV[0]).each do |line|
  if line =~ /\d+-\d+-\d+\s\d+:(\d+):(\d+)\.(\d+)\s/ 
     o << $1.to_f*60.0 + $2.to_f + $3.to_f/1000.0;
  end
end

for k in 1...o.length
   printf "%.3f,", o[k] - o[k-1] 
end

puts "\n"

for k in 1...o.length
   printf "-%.1f,", 40.0
end

puts "\n"
