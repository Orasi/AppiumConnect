# AppiumConnect
Simple Ruby Gem to dynamically create Appium Node Config files for any mobile device connected via USB.

#Install
AppiumConnect is available to install from RubyGems.
```ruby
gem install appium_connect
'''
This will add an executable that can be run from command line
'''
AppiumConnect
'''

For Android devices this will use ADB to detect any devices currently connected and create a seperate AppiumNode for each one. When Appium Connect first starts it will ask for the IP address to use for the hub, and the node.  Once these are provided they will be remembered (saved in config.json) and it can automatically connect.
***********************************************************


# Orasi Software Inc
Orasi is a software and professional services company focused on software quality testing and management.  As an organization, we are dedicated to best-in-class QA tools, practices and processes. We are agile and drive continuous improvement with our customers and within our own business.

# License
Licensed under [BSD License](/License)