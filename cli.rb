require "optparse"

input = STDIN
output = STDOUT

parser = OptionParser.new
parser.banner = "Usage: footgauntlet [options]"

parser.on("-i", "--input ")
