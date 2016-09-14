require 'pp'

desc "Display compliled config variables"
command ['display-config'] do |c|
  c.action do |global_options, options, args|
    puts "Gloabal Config:\n"
    pp Megamaid::GlobalConfig.config
  end
end
