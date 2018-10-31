module SlackGamebot
  module Commands
    class Lost < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        reporter = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        arguments = expression.split.reject(&:blank?) if expression

        scores = nil
        opponents = []
        teammates = [reporter]
        reporter_team = nil
        opponent_team = nil
        multi_player = expression && expression.include?(' with ')

        current = :scores
        while arguments && arguments.any?
          argument = arguments.shift
          case argument
          when 'to' then
            current = :opponents
          when 'with' then
            current = :teammates
          when 'using' then
            current = :reporter_team
          when 'vs.', 'vs' then
            current = :opponent_team
          else
            if current == :opponents
              opponents << ::User.find_by_slack_mention!(client.owner, argument)
              current = :scores unless multi_player
            elsif current == :teammates
              teammates << ::User.find_by_slack_mention!(client.owner, argument)
              current = :scores if opponents.count == teammates.count
            elsif current == :scores
              scores ||= []
              scores << Score.check(argument)
            elsif current == :reporter_tean
              reporter_team ||= []
              reporter_team << argument
            elsif current == :opponent_team
              opponent_team ||= []
              opponent_team << argument
            end
          end
        end

        if(reporter_team && opponent_team)
          reporter_team = reporter_team.join(' ')
          opponent_team = opponent_team.join(' ')
        end

        if opponents.nil? || scores.nil? || scores.empty?
          client.say(channel: data.channel, text: "Please enter the scores in the form `pp lost to @opponent1 @opponent2 with @teammate 41:55 using Your Team vs. Their Team`", gif: 'error')
          return
        end

        report = ::Report.create_from_teammates_and_opponents!(client.owner, data.channel, teammates, opponents, scores, reporter_team, opponent_team)
        client.say(channel: data.channel, text: report.to_s, gif: 'lose')
        logger.info "REPORT: #{client.owner} - #{report}"
      end
    end
  end
end
