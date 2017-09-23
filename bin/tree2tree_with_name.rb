nodes = File.readlines("nodes.txt").map(&:chomp)

open(File.basename(ARGV[0], ".*") + ".tree_named", "w") do |out|
  open(ARGV[0], "r") do |input|
    input.each_line do |line|
      line = line.sub(/"([^"]+)"/) { |m| %("#{nodes[$1.to_i]}") }
      out.puts(line)
    end
  end
end
