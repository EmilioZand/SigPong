module Api
  module Endpoints
    class MatchesEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :matches do

        desc 'Get all the matches for a user'
        params do
          requires :team_id, type: String
          requires :user_name, type: String, desc: 'User name.'
          use :pagination
        end
         sort Match::SORT_ORDERS
         get 'user' do
          team = Team.find(params[:team_id]) || error!('Not Found', 404)
          user = User.where(team: team, user_name: params[:user_name]).first || error!('Not Found', 404)
          matches = paginate_and_sort_by_cursor(user.current_matches, default_sort_order: '-_id')
          error!('Not Found', 404) unless user.team.api?
          present matches, with: Api::Presenters::MatchesPresenter
        end
        
        desc 'Get a match.'
        params do
          requires :id, type: String, desc: 'Match ID.'
        end
        get ':id' do
          match = Match.find(params[:id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless match.team.api?
          present match, with: Api::Presenters::MatchPresenter
        end

        desc 'Get all the matches.'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort Match::SORT_ORDERS
        get do
          team = Team.find(params[:team_id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless team.api?
          matches = paginate_and_sort_by_cursor(team.matches, default_sort_order: '-_id')
          present matches, with: Api::Presenters::MatchesPresenter
        end

        desc 'Delete a status.'
        params do
          requires :id, type: String, desc: 'Match ID.'
        end
        delete ':id' do
          match = Match.find(params[:id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless match.team.api?
          match.delete_and_reset_score
        end
      end
    end
  end
end
