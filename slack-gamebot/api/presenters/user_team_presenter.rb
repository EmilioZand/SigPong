module Api
    module Presenters
      module UserTeamPresenter
        include Roar::JSON::HAL
        include Roar::Hypermedia
        include Grape::Roar::Representer
  
        property :id, type: String, desc: 'UserTeam ID.'
        property :user_name, type: String, desc: 'UserTeam name.'
        property :team_name, type: String, desc: 'UserTeam name.'
        property :wins, type: Integer, desc: 'Number of wins.'
        property :losses, type: Integer, desc: 'Number of losses.'
        property :played, type: Integer, desc: 'Number of games played.'
  
        link :user do |opts|
          request = Grape::Request.new(opts[:env])
          "#{request.base_url}/users/#{user_id}"
        end
      end
    end
  end
  