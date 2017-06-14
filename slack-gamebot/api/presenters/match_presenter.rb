module Api
  module Presenters
    module MatchPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id, type: String, desc: 'Match ID.'
      property :tied, type: Boolean, desc: 'Match is a tie.'
      property :resigned, type: Boolean, desc: 'The loser resigned.'
      property :scores, type: Array, desc: 'Match scores.'
      property :created_at, type: DateTime, desc: 'Date/time when the match was created.'
      collection :winners, extend: UserPresenter, as: :winners
      collection :losers, extend: UserPresenter, as: :losers

      link :team do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/teams/#{represented.team.id}" if represented.team
      end

      link :challenge do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/challenges/#{represented.challenge.id}" if represented.challenge
      end

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/matches/#{id}"
      end
    end
  end
end
