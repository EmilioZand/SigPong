module Api
  module Endpoints
    class UserTeamsEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :user_teams do

        desc 'Get all the teams for a user'
        params do
          requires :user_id, type: String, desc: 'User ID.'
          use :pagination
        end
        sort UserTeam::SORT_ORDERS
        get 'user_teams' do
          user = User.find(params[:user_id]) || error!('Not Found', 404)
          teams = UserTeam.where(user: user) || error!('Not Found', 404)
          user_teams = paginate_and_sort_by_cursor(teams, default_sort_order: '-_id')
          error!('Not Found', 404) unless user.team.api?
          present user_teams, with: Api::Presenters::UserTeamsPresenter
        end

        desc 'Get a UserTeam.'
        params do
          requires :id, type: String, desc: 'UserTeam ID.'
        end
        get ':id' do
          user_team = UserTeam.find(params[:id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless user_team.team.api?
          present user_team, with: Api::Presenters::UserTeamPresenter
        end

        desc 'Get all the UserTeams.'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort UserTeam::SORT_ORDERS
        get do
          team = Team.find(params[:team_id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless team.api?
          user_teams = paginate_and_sort_by_cursor(team.user_teams, default_sort_order: '-_id')
          present user_teams, with: Api::Presenters::UserTeamsPresenter
        end
      end
    end
  end
end
