
def get_platform()
  if Gem::Platform.local.os == 'darwin'
    return :mac
  elsif Gem::Platform.local.os == 'linux'
    return :linux
  else
    return :windows
  end
end

def generate_node_config(nodeDir, file_name, udid, appium_port, ip, hubIp, platform, browser)
  f = File.new(nodeDir + "/node_configs/#{file_name}", "w")

  f.write( JSON.generate({ capabilities: [
                                          { udid: udid,
                                            browserName: udid,
                                            maxInstances: 1,
                                            platform: platform,
                                            deviceName: udid,
                                            applicationName: udid
                                          },

                                          { browserName: browser,
                                            maxInstances: 1,
                                            deviceName: udid,
                                            udid: udid,
                                            seleniumProtocol: 'WebDriver',
                                            platform: platform ,
                                            applicationName: udid}],

                           configuration: { cleanUpCycle: 2000,
                                            timeout: 299000,
                                            registerCycle: 5000,
                                            proxy: "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
                                            url: "http://#{ip}:#{appium_port}/wd/hub",
                                            host: ip,
                                            port: appium_port,
                                            maxSession: 1,
                                            register: true,
                                            hubPort: 4444,
                                            hubHost: hubIp } } ) )
  f.close
end


def create_dir(name)
  FileUtils::mkdir_p name
end