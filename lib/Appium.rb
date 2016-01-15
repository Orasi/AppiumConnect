
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



def launch_hub_and_nodes(ip, hubIp, nodeDir)

  if Gem::Platform.local.os == 'darwin'

    ios_devices = JSON.parse(get_ios_devices)

    ios_devices.size.times do |index|
      port = 4100 + index
      config_name = "#{ios_devices[index]["udid"]}.json"
      generate_node_config nodeDir, config_name, ios_devices[index]["udid"], port, ip, hubIp, 'MAC', 'safari'
      node_config = nodeDir + 'node_configs/' +"#{config_name}"
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
      generate_node_config nodeDir, config_name, devices[index]["udid"], port, ip, hubIp, 'android', 'chrome'
      node_config = nodeDir + 'node_configs/' +"#{config_name}"
      if sdkv === 16 || sdkv === 17
        appium_server_start config: node_config, port: port, bp: bp, udid: devices[index]["udid"], automationName: "selendroid", selendroidPort: sdp, log: "appium-#{devices[index]["udid"]}.log", tmp: devices[index]["udid"], cp: cp
      else
        appium_server_start config: node_config, port: port, bp: bp, udid: devices[index]["udid"], log: "appium-#{devices[index]["udid"]}.log", tmp: devices[index]["udid"], cp: cp
      end
    end
  end
end
