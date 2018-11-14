module Api
  module Presenters
    module UserTeamsPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer
      include Api::Presenters::PaginatedPresenter

      collection :results, extend: UserTeamPresenter, as: :user_teams, embedded: true
    end
  end
end
