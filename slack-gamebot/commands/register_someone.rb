module SlackGamebot
  module Commands
    class RegisterSomeone < SlackRubyBot::Commands::Base
       def self.call(client, data, match)
        arguments = match['expression'].split.reject(&:blank?) if match['expression']
        user = arguments[0]
        if user
        
          users = User.find_create_or_update_by_mention!(user)
        end
        user.register! if user && !user.registered?
        message = if user.created_at >= ts
                    "<@#{data.user}> you have registered <@#{user}>"
                  else
                    "<@#{user}> is already registered"
        end
        client.say(channel: data.channel, text: message, gif: 'welcome')
        user
      end
    end
  end
end
