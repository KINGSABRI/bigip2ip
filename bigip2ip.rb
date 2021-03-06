#!/usr/bin/env ruby
#
# BigIP2IP is F5 cookies decoder to disclose local servers ip
#
#=> Decimal
# printf 'GET / HTTP/1.0\nHOST:domain.com\n\n' | ncat domain.com 80  | grep -i bigip
# BIGipServerPool=252029120.10499.0000
#=> Hex
# printf 'GET / HTTP/1.0\nHOST:domain.com\n\n' | ncat --ssl domain.com 443  | grep -i bigip
# BIGipServerpool_=rd4o00000000000000000000ffffc0a80411o80
# Read All BigIP Techinques in IP encoding
# http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html


require 'optparse'

class String
  def red; colorize(self, "\e[31m"); end
  def green; colorize(self, "\e[32m"); end
  def bold; colorize(self, "\e[1m"); end
  def underline; colorize(self, "\e[4m"); end
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

  opts.on('--decimal DECIMAL', 'Convert decimal to doted format') do |o|
    options[:decimal] = o
  end

  opts.on('--hex HEX', 'Convert Hex(non-default route domains) to doted decimal format') do |o|
    options[:hex] = o
  end

  opts.on('--list', 'List all supported products with its versions') do |o|
    options[:list] = o
  end

  opts.banner = "\nUsage:".underline + " ruby bigip2ip.rb {OPTIONS} COOKIE\n\n"

  opts.on( '-h', '--help', "Display help screen\n" ) do |o|
    options[:help] = o
  end
end

optparse.parse!
options
ARGV

case
  #--> Decimal
  when options[:decimal]
    # Cookie parsing
    options[:decimal] = options[:decimal].split("=").last.split(".").first
    puts "#{options[:decimal]}".to_i.to_decimal
  #--> Hex
  when options[:hex]
    # Cookie parsing
    options[:hex] = options[:hex].split("f").last.split("o").first
    puts "#{options[:hex]}".hex.to_i.to_decimal_reverse
  #--> Products list
  when options[:list]
    puts "Product name" + "|" + "supported version"
    supported_products.each do |prod, ver|
      puts "[+] ".red + "#{prod}".bold.ljust(35," ") + "#{ver.join(" ")}".green
    end
    puts "\n[+] ".red + "Visit: http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html"

  else
    puts optparse
    puts "\nExamples:".underline
    puts "ruby bigip2ip.rb --decimal BIGipServerPool=252029120.10499.0000"
    puts "ruby bigip2ip.rb --hex BIGipServerpool=rd4o00000000000000000000ffffc0a80411o80"
    puts "ruby bigip2ip.rb --list"
end

