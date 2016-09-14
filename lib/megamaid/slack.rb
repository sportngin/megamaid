require 'httparty'

module Megamaid
  class SlackNotification
    attr_accessor :slack_params

    def initialize(options = {})
      self.slack_params = (GlobalConfig.slack || {}).merge options
    end

    def username
      slack_params[:username]
    end

    def icon_url
      slack_params[:icon_url]
    end

    def webhook
      slack_params[:webhook]
    end

    def payload
      {
          username: username,
          icon_url: icon_url
      }
    end

    def post_message(msg)
      HTTParty.post(
          webhook,
          body: "payload=#{payload.merge({text: msg}).to_json}"
      )
    end

  end
end
