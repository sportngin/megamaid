require 'httparty'

module Megamaid
  class Amirite
    def initialize(env)
      @ops = AwsClients.opsworks
      @ec2 = AwsClients.ec2
      @problem_layers = []
      @env = env
    end

    def stacks
      @ops.describe_stacks.stacks
    end

    def layers(stack_id)
      @ops.describe_layers(:stack_id => stack_id).layers
    end

    def stack_name(stack_id)
      @ops.describe_stack_summary(:stack_id => stack_id).stack_summary.name
    end

    def layer_name(layer_id)
      @ops.describe_layers(:layer_ids => [layer_id]).layers[0].shortname
    end

    def ami_name(ami_id)
      ami = @ec2.describe_images(:image_ids=>[ami_id])
      return ami_id unless ami.images.length > 0
      ami.images[0].name || ami_id
    rescue
      ami_id
    end

    def instances(layer_id)
      @ops.describe_instances(:layer_id => layer_id).instances
    end

    def check_amis
      puts "Verifying AMI Consistency..."
      stacks.each do |s|
        debug_say "\nStack: #{stack_name(s.stack_id)}"
        layers(s.stack_id).each do |l|
          debug_say "  |-Layer: #{layer_name(l.layer_id)}"
          amis = []
          families = []
          hosts = instances(l.layer_id)
          hosts.each do |i|
            debug_say "  |  |-Host: #{i.hostname} (#{i.ami_id}/#{ami_name(i.ami_id)}) [#{ami_name(i.instance_type)}]"
            next unless i.ami_id # Skip host analysis if the AMI isn't defined.
            amis << i.ami_id unless amis.include?(i.ami_id)
            family = i.instance_type.split('.')[0]
            families << family unless families.include?(family)
          end
          if amis.length > 1
            ignore_words = %w(Instance EBS)
            ignore_words.concat(%w(HVM PV)) if families.length > 1
            ami_names = []
            amis.each do |a|
              name = ami_name(a)
              ignore_words.each do |w|
                name.slice! w
              end
              ami_names << name unless ami_names.include?(name)
            end
            report_problem({:stack_id => l.stack_id, :layer_id => l.layer_id, :instances => hosts}) if ami_names.length > 1
          end
        end
      end
    end

    def report_problem(layer_info)
      debug_say "  |  |- ** Found AMI inconsistency ** "
      @problem_layers << layer_info
    end

    def formatted_results
      return "No AMI inconsisencies found in #{@env}!" unless @problem_layers.length > 0

      msg = "Some AMIs don't look quite right in #{@env}"
      @problem_layers.each do |l|
        msg << "\n```Layer: #{stack_name(l[:stack_id])}/#{layer_name(l[:layer_id])}"
        maxchar = l[:instances].reduce(0) do |count, item|
          [count,item.hostname.length+item.status.length].max
        end

        l[:instances].each do |i|
          padding = " " * (maxchar-(i.hostname.length+i.status.length))
          msg << "\n  |- #{i.hostname} (#{i.status}) #{padding}- #{ami_name(i.ami_id)} [#{ami_name(i.instance_type)}]"
        end
        msg << "\n```"
      end
      return msg
    end

    def send_to_slack(msg)
     slack = SlackNotification.new( username: "AMIRITE?", icon_url: "http://ci.memecdn.com/376/2709376.jpg" )
     slack.post_message(msg)
    end

    def debug_say(msg)
      puts msg if GlobalConfig.debug
    end

    def run
      check_amis
      send_to_slack(formatted_results)
    end
  end
end
