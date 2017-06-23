module SlackGamebot
  module Commands
    class Contest < SlackRubyBot::Commands::Base
      def self.call(client, data, _match)
        player = ::User.find_create_or_update_by_slack_id!(client, data.user)
        report = ::Report.find_by_opponent(client.owner, data.channel, player)
        if report
          report.contest!(player)
          client.say(channel: data.channel, text: "#{report.opponents.map(&:user_name).and} contested #{report.reporters.map(&:user_name).and}'s reported score. Please report the actual score.", gif: 'wrong')
          logger.info "ACCEPT: #{client.owner} - #{report}"
        else
          client.say(channel: data.channel, text: 'No reports to contest!')
          logger.info "ACCEPT: #{client.owner} - #{data.user}, N/A"
        end
      end
    end
  end
end
