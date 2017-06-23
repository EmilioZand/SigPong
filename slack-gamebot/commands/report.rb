module SlackGamebot
  module Commands
    class Report < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        reporter = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        arguments = expression.split.reject(&:blank?) if expression

        scores = nil
        opponent = nil

        current = :opponent
        while arguments && arguments.any?
          argument = arguments.shift
          if current == :opponent
            opponent = User.find_by_slack_mention!(client.owner, argument)
            current = :scores
          else
            scores ||= []
            scores << Score.check(argument)
          end
        end

        if opponent.nil? || scores.nil? || scores.empty?
          client.say(channel: data.channel, text: "Please enter the scores in the form `pp report @user 21:0 0:21 21:0`", gif: 'error')
          return
        end

        report = ::Report.create_from_teammates_and_opponents!(client.owner, data.channel, reporter, opponent, scores)

        if report.reporter_won?
          client.say(channel: data.channel, text: report.to_s, gif: 'winner')
        else
          client.say(channel: data.channel, text: report.to_s, gif: 'loser')
        end
        logger.info "REPORT: #{client.owner} - #{report}"
      end
    end
  end
end
