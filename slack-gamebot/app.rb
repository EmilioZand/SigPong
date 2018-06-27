module SlackGamebot
  class App < SlackRubyBotServer::App
    include Celluloid

    DEAD_MESSAGE = <<-EOS.freeze
This leaderboard has been dead for over a month, deactivating.
Re-install the bot at https://www.playplay.io. Your data will be purged in 2 weeks.
EOS

    def after_start!
      once_and_every 60 * 3 do
        ping_teams!
      end
    end

    private

    def once_and_every(tt)
      yield
      every tt do
        yield
      end
    end

    def ping_teams!
      Team.active.each do |team|
        begin
          ping = team.ping!
          next if ping[:presence].online
          logger.warn "DOWN: #{team}"
          after 60 do
            ping = team.ping!
            unless ping[:presence].online
              logger.info "RESTART: #{team}"
              SlackGamebot::Service.instance.start!(team)
            end
          end
        rescue StandardError => e
          logger.warn "Error pinging team #{team}, #{e.message}."
        end
      end
    end
  end
end