module Megamaid
  module Helpers

    def add_slack_attachment

    end

    def send_to_slack(msg)
      slack = SlackNotification.new( username: "AMIRITE?", icon_url: "http://ci.memecdn.com/376/2709376.jpg" )
      slack.post_message(msg)
    end

    def debug_say(msg)
      puts msg if GlobalConfig.debug
    end

  end
end
