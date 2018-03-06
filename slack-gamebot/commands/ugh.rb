module SlackGamebot
  module Commands
    class Ugh < SlackRubyBot::Commands::Base
      def self.call(client, data, _match)
        player = ::User.find_create_or_update_by_slack_id!(client, data.user)
        report = ::Report.find_by_opponent(client.owner, data.channel, player)
        if report
          report.confirm!(player)
          outcome_verb = report.reporter_won? ? "beat" : "lost to"
          client.say(channel: data.channel, text: "Joke's on you, #{report.opponents.map(&:display_name).and}! #{report.reporters.map(&:display_name).and} #{outcome_verb} you and you're just going to have to deal with it.", gif: 'deal with it')
          logger.info "BEGRUDGINGLY ACCEPT: #{client.owner} - #{report}"
        else
          client.say(channel: data.channel, text: "No reports to complain about! If you're just having a bad time, this may help:", gif: "#{['puppy', 'kitten', 'baby goat'].sample} fail")
          logger.info "BEGRUDGINGLY ACCEPT: #{client.owner} - #{data.user}, N/A"
        end
      end
    end
  end
end
