module SlackGamebot
  module Commands
    class Challenge < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        challenger = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if challenger.registered?
          arguments = match['expression'].split.reject(&:blank?) if match['expression']
          arguments ||= []
          challenge_string = ::Challenge.create_unofficial_challenge(client.owner, data.channel, challenger, arguments)
          client.say(channel: data.channel, text: challenge_string, gif: 'challenge')
          logger.info "CHALLENGE: #{client.owner}"
        else
          client.say(channel: data.channel, text: "You aren't registered to play, please _register_ first.", gif: 'register')
          logger.info "CHALLENGE: #{client.owner} - #{challenger.user_name}, failed, not registered"
        end
      end
    end
  end
end
