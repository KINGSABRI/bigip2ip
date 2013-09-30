#!/usr/bin/env ruby
#
#cla => Decimal
# printf 'GET / HTTP/1.0\nHOST:domain.com\n\n' | ncat domain.com 80  | grep -i bigip
# BIGipServerPool_cla=252029120.10499.0000
#
# saaf => Hex
# printf 'GET / HTTP/1.0\nHOST:saaf.domain.com\n\n' | ncat --ssl saaf.domain.com 443  | grep -i bigip
# BIGipServerpool_SaafFarm_4.17-24=rd4o00000000000000000000ffffc0a80411o80
#
# header = "BIGipServerPool_cla=252029120.10499.0000".split("=").last.split(".").first #=> "252029120"
# Read All BigIP Techinques in IP encoding
# http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html
#
# from big up to ip
# s = 1677787402.to_s 16 # "6401010a"   << Hex
# ss = s.scan(/.{2}/)   #=> ["64", "01", "01", "0a"]
# sss = ss.reverse.map {|o| o.hex}.join(".")  #=> "100.1.1.10"
#

require 'optparse'

class String
  def red; colorize(self, "\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def bold; colorize(self, "\e[1m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end


class Integer

  def to_decimal
    number = self
    result = []
    4.times do
	result.push number & 255
	number = number >> 8
    end

    result.join('.')
  end

  def to_decimal_reverse
    number = self
    result = []
    4.times do
      result.push number & 255
      number = number >> 8
    end

    result.reverse.join('.')
  end

end

#
# List of all supported products
# http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html
#
supported_products =
    {
        "BIG-IP: LTM"             => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0, 9.6.1, 9.6.0, 9.4.8, 9.4.7, 9.4.6, 9.4.5, 9.4.4, 9.4.3, 9.4.2, 9.4.1, 9.4.0, 9.3.1, 9.3.0, 9.2.5, 9.2.4, 9.2.3, 9.2.2, 9.2.0, 9.1.3, 9.1.2, 9.1.1, 9.1.0, 9.0.5, 9.0.4, 9.0.3, 9.0.2, 9.0.1, 9.0.0},
        "BIG-IP: APM"             => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0},
        "BIG-IP: ASM"             => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0, 9.4.8, 9.4.7, 9.4.6, 9.4.5, 9.4.4, 9.4.3, 9.4.2, 9.4.1, 9.4.0, 9.3.1, 9.3.0, 9.2.5, 9.2.4, 9.2.3, 9.2.2, 9.2.0},
        "BIG-IP: Edge-Gateway"    => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0},
        "BIG-IP: Link-Controller" => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0, 9.4.8, 9.4.7, 9.4.6, 9.4.5, 9.4.4, 9.4.3, 9.4.2, 9.4.1, 9.4.0, 9.3.1, 9.3.0, 9.2.5, 9.2.4, 9.2.3, 9.2.2},
        "BIG-IP: PSM"             => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0, 9.4.8, 9.4.7, 9.4.6, 9.4.5},
        "BIG-IP: WebAccelerator"  => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0, 9.4.8, 9.4.7, 9.4.6, 9.4.5, 9.4.4, 9.4.3, 9.4.2, 9.4.1, 9.4.0},
        "BIG-IP: WOM"             => %w{11.2.1, 11.2.0, 11.1.0, 11.0.0, 10.2.4, 10.2.3, 10.2.2, 10.2.1, 10.2.0, 10.1.0, 10.0.1, 10.0.0}
    }



options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]  VALUE"

  opts.on("--decimal2dot DECIMAL", "Convert decimal to doted format") do |o|
    options[:decimal2dot] = o
  end

  opts.on("--dot2decimal IP-ADDR", "Convert doted to decimal format") do |o|
    options[:dot2decimal] = o
  end

  opts.on("--hex2dotdecimal HEX", "Convert Hex(non-default route domains) to doted decimal format") do |o|
    options[:hex2dotdecimal] = o
  end

  opts.on("--list", "List all supported products with its versions") do |o|
    options[:list] = o
  end

  opts.on( '-h', '--help', "Display help screen\n" ) 	do
    puts opts
    puts "\nExamples:\n" + "ruby bigip2ip.rb --decimal2dot 252029120"
  end

end

optparse.parse!
options
ARGV

case
  #-->
  when options[:decimal2dot]
    puts "#{options[:decimal2dot]}".to_i.to_decimal
  when options[:hex2dotdecimal]
    puts "#{options[:hex2dotdecimal]}".hex.to_i.to_decimal_reverse
  when options[:list]
    puts "Product name" + "|" + "supported version"
    supported_products.each do |prod, ver|
      puts "[+] ".red + "#{prod}".bold.ljust(35," ") + "#{ver.join(", ")}".green
    end
    puts "\n[+] ".red + "Visit: http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html"
  else
    puts optparse
end








