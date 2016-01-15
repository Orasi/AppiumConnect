def get_ios_devices
  ENV["IOS_DEVICES"] = JSON.generate((`system_profiler SPUSBDataType | sed -n -E -e '/(iPhone|iPad)/,/Serial/s/ *Serial Number: *(.+)/\\1/p'`).lines.map.each_with_index { |line, index| { udid: line.gsub(/\n/,""), thread: index + 1 } })
end
