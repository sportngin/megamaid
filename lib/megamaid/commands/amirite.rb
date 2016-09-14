desc "Verify all instances in each OpsWorks layer are running consistent AMIs"
command :amirite do |c|
  c.action do |global_options, options, args|
    puts "AMIRITE??"
    Megamaid::Amirite.new(Megamaid::GlobalConfig.profile).run
  end
end
