#!/usr/bin/ruby
# Source: https://github.com/claudijd/utility-belt/blob/master/f5bigip/cookie_decode.rb
# Reference:
# I cleaned up the code from here to meet my personal preferences
# http://gursevkalra.blogspot.com/2011/12/decoding-bigip-cookie.html

# Example Output
# $ ruby f5bigip/cookie_decode.rb 404007104.20480.0000
# IP Address : 192.168.20.24
# Port       : 80

# Example BigIP Cookie to demonstrate the concept
example = "404007104.20480.0000"
cookie = ARGV[0] || example

encoded_ip, encoded_port = cookie.split(".")
encoded_ip_int = encoded_ip.to_i
encoded_port_int = encoded_port.to_i

ip_array = []
port_array = []

4.times do
  ip_array << encoded_ip_int % 256
  encoded_ip_int /= 256
end

2.times do
  port_array << encoded_port_int % 256
  encoded_port_int /= 256
end

puts "IP Address : #{ip_array.join(".")}"
puts "Port       : #{port_array[0]*256 + port_array[1]}"
