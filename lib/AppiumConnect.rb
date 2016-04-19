#Copyright © 2016 Orasi Software, Inc., All rights reserved.

require 'parallel'
require 'json'
require 'fileutils'


require_relative 'FileSystemHelpers'
require_relative 'Android'
require_relative 'Appium'
require_relative 'iOS.rb'

platform = get_platform()
if platform == :windows
  require 'Win32API'
end

def shortname long_name
  max_path = 1024
  short_name = " " * max_path
  lfn_size = Win32API.new("kernel32", "GetShortPathName", ['P','P','L'],'L').call(long_name, short_name, max_path)
  return short_name[0..lfn_size-1]
end

input_array = ARGV
if input_array.include? '--restart'
  restart_devices
else

  platform = get_platform()
  if platform == :linux
    nodeConfigDir = File.expand_path('~/AppiumConnect/')
  elsif platform == :mac
    nodeConfigDir = File.expand_path('~/AppiumConnect/')
  elsif platform == :windows
    nodeConfigDir = shortname(Dir.home() + '/AppiumConnect')
  end

  create_dir nodeConfigDir
  create_dir nodeConfigDir + '/node_configs'
  create_dir nodeConfigDir + '/output'


  if File.exist?(nodeConfigDir + '/config.json')
    config = JSON.parse(File.read(nodeConfigDir +'/config.json'))

    puts ''
    puts 'Config file detected. Press enter to use last setting or any other key to edit:'
    puts "Hub: #{config['hubIp']}   Node: #{config['nodeIp']}"

    if gets.chomp() != ''

      puts ''
      puts 'Please Enter IP address of Hub:'
      hubIp = gets.chomp()

      puts ''
      puts ''
      puts 'Please Enter IP address of Node:'

      ip = gets.chomp()

      config = {hubIp: hubIp, nodeIp: ip}
      File.open(nodeConfigDir + '/config.json', 'w') do |f|
        f.write(config.to_json)
      end

    end
  else

    puts ''
    puts 'Please Enter IP address of Hub:'
    hubIp = gets.chomp()

    puts ''
    puts ''
    puts 'Please Enter IP address of Node:'
    ip = gets.chomp()

    config = {hubIp: hubIp, nodeIp: ip}

    File.open(nodeConfigDir + '/config.json', 'w') do |f|
      f.write(config.to_json)
    end

  end

  p nodeConfigDir
  launch_hub_and_nodes config['nodeIp'], config['hubIp'], nodeConfigDir
end

