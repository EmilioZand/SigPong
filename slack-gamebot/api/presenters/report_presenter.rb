module Api
  module Presenters
    module ReportPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id, type: String, desc: 'Report ID.'
      property :state, type: String, desc: 'Current state of the report.'
      property :channel, type: String, desc: 'Channel where the report was created.'
      property :created_at, type: DateTime, desc: 'Date/time when the report was created.'
      property :updated_at, type: DateTime, desc: 'Date/time when the report was accepted, declined or canceled.'
      property :scores, type: Array, desc: 'Match scores.'
      property :reporter_won, type: Boolean, desc: 'Did the reporter win?'
      property :reporter_team, type: String, desc: 'Team winners used.'
      property :opponent_team, type: String, desc: 'Team winners used.'
      collection :reporters, extend: UserPresenter, as: :reporters
      collection :opponents, extend: UserPresenter, as: :opponents

      link :team do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/teams/#{represented.team.id}" if represented.team
      end

      link :created_by do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/users/#{represented.created_by.id}" if represented.created_by
      end

      link :updated_by do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/users/#{represented.updated_by.id}" if represented.updated_by
      end

      link :reporters do |opts|
        request = Grape::Request.new(opts[:env])
        represented.reporters.map do |reporters|
          "#{request.base_url}/users/#{reporters.id}"
        end
      end

      link :opponents do |opts|
        request = Grape::Request.new(opts[:env])
        represented.opponents.map do |opponents|
          "#{request.base_url}/users/#{opponents.id}"
        end
      end

      link :match do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/matches/#{represented.match.id}" if represented.match
      end

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/reports/#{id}"
      end
    end
  end
end
