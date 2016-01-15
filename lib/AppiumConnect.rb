#Copyright © 2016 Orasi Software, Inc., All rights reserved.

require 'parallel'
require 'json'
require 'fileutils'

def get_android_devices
  ENV["DEVICES"] = JSON.generate((`adb devices`).lines.select { |line| line.match(/\tdevice$/) }.map.each_with_index { |line, index| { udid: line.split("\t")[0], thread: index + 1 } })
end

def get_ios_devices
  ENV["IOS_DEVICES"] = JSON.generate((`system_profiler SPUSBDataType | sed -n -E -e '/(iPhone|iPad)/,/Serial/s/ *Serial Number: *(.+)/\\1/p'`).lines.map.each_with_index { |line, index| { udid: line.gsub(/\n/,""), thread: index + 1 } })
end

def get_device_osv udid
  command = "adb  -s #{udid} shell getprop ro.build.version.sdk"
  `#{command}`
end

def appium_server_start(**options)
  command = 'appium'
  command << " --nodeconfig #{options[:config]}" if options.key?(:config)
  command << " -p #{options[:port]}" if options.key?(:port)
  command << " -bp #{options[:bp]}" if options.key?(:bp)
  command << " --udid #{options[:udid]}" if options.key?(:udid)
  command << " --automation-name #{options[:automationName]}" if options.key?(:automationName)
  command << " --selendroid-port #{options[:selendroidPort]}" if options.key?(:selendroidPort)
  command << " --log #{Dir.pwd}/output/#{options[:log]}" if options.key?(:log)
  command << " --tmp /tmp/#{options[:tmp]}" if options.key?(:tmp)
  command << " --chromedriver-port #{options[:cp]}" if options.key?(:cp)
  command << " --command-timeout 180"
  Dir.chdir('.') {
    if Gem::Platform.local.os == 'linux'
      pid = system('x-terminal-emulator -e ' + command)
    elsif Gem::Platform.local.os == 'darwin'
      `osascript -e 'tell app "Terminal" to do script "#{command}"'`
    else
      pid = system('start ' + command)
    end

    puts 'Waiting for Appium to start up...'
    sleep 5

    if pid.nil?
      puts 'Appium server did not start :('
    end
  }
end

def generate_node_config(file_name, udid, appium_port, ip, hubIp, platform, browser)
  f = File.new(Dir.pwd + "/node_configs/#{file_name}", "w")
  f.write( JSON.generate({ capabilities: [{ udid: udid, browserName: udid, maxInstances: 1, platform: platform,  deviceName: udid },{ browserName: browser, maxInstances: 1,  deviceName: udid, udid: udid, seleniumProtocol: 'WebDriver', platform: platform , applicationName: udid}],
                           configuration: { cleanUpCycle: 2000, timeout: 180000, registerCycle: 5000, proxy: "org.openqa.grid.selenium.proxy.DefaultRemoteProxy", url: "http://" + ip + ":#{appium_port}/wd/hub",
                                            host: ip, port: appium_port, maxSession: 1, register: true, hubPort: 4444, hubHost: hubIp } } ) )
  f.close
end

def launch_hub_and_nodes(ip, hubIp)

  if Gem::Platform.local.os == 'darwin'

    ios_devices = JSON.parse(get_ios_devices)

    ios_devices.size.times do |index|
      port = 4100 + index
      config_name = "#{ios_devices[index]["udid"]}.json"
      generate_node_config config_name, ios_devices[index]["udid"], port, ip, hubIp, 'MAC', 'safari'
      node_config = Dir.pwd + '/node_configs/' +"#{config_name}"
      appium_server_start config: node_config, port: port, udid: ios_devices[index]["udid"], log: "appium-#{ios_devices[index]["udid"]}.log", tmp: ios_devices[index]["udid"]
    end

  else

    devices = JSON.parse(get_android_devices)

    devices.size.times do |index|
      port = 4000 + index
      bp = 2250 + index
      sdp = 5000 + index
      cp = 6000 + index
      sdkv = get_device_osv(devices[index]['udid']).strip.to_i
      config_name = "#{devices[index]["udid"]}.json"
      generate_node_config config_name, devices[index]["udid"], port, ip, hubIp, 'android', 'chrome'
      node_config = Dir.pwd + '/node_configs/' +"#{config_name}"
      if sdkv === 16 || sdkv === 17
        appium_server_start config: node_config, port: port, bp: bp, udid: devices[index]["udid"], automationName: "selendroid", selendroidPort: sdp, log: "appium-#{devices[index]["udid"]}.log", tmp: devices[index]["udid"], cp: cp
      else
        appium_server_start config: node_config, port: port, bp: bp, udid: devices[index]["udid"], log: "appium-#{devices[index]["udid"]}.log", tmp: devices[index]["udid"], cp: cp
      end
    end
  end
end

def create_dir(name)
  FileUtils::mkdir_p name
end

create_dir 'node_configs'
create_dir 'output'
if File.exist?('config.json')
  config = JSON.parse(File.read('config.json'))

  puts ''
  puts 'Config file detected. Press enter to use last setting:'
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
    File.open('config.json', 'w') do |f|
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
  File.open('config.json', 'w') do |f|
    f.write(config.to_json)
  end

end



launch_hub_and_nodes(config['nodeIp'], config['hubIp'])
