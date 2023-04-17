STDIN.each_line do |line|
  line.chomp!.reverse!
  STDOUT.puts(line)
  STDOUT.flush
end
