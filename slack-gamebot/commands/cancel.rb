module SlackGamebot
  module Commands
    class Cancel < SlackRubyBot::Commands::Base
      def self.call(client, data, _match)
        player = ::User.find_create_or_update_by_slack_id!(client, data.user)
        report = ::Report.find_by_reporter(client.owner, data.channel, player)
        if report
          report.cancel!(player)
          client.say(channel: data.channel, text: "#{player.user_name} cancelled challenge against #{report.opponents.map(&:user_name).and}.", gif: 'cancel')
          logger.info "ACCEPT: #{client.owner} - #{report}"
        else
          client.say(channel: data.channel, text: 'No reports to cancel!')
          logger.info "ACCEPT: #{client.owner} - #{data.user}, N/A"
        end
      end
    end
  end
end
