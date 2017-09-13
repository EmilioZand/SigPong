module Api
  module Endpoints
    class UsersEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :users do
        desc 'Get all ranked users'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort User::SORT_ORDERS
        get 'ranked' do
          team = Team.find(params[:team_id]) || error!('team_id not supplied', 500)
          error!("Team #{team_id} API not enabled", 404) unless team.api?
          query = team.users.placed
          users = paginate_and_sort_by_cursor(query, default_sort_order: '-elo')
          present users, with: Api::Presenters::UsersPresenter
        end

        desc 'Get all unranked users'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort User::SORT_ORDERS
        get 'unranked' do
           team = Team.find(params[:team_id]) || error!('team_id not supplied', 500)
          error!("Team #{team_id} API not enabled", 404) unless team.api?
          query = team.users.unplaced
          users = paginate_and_sort_by_cursor(query, default_sort_order: '-elo')
          present users, with: Api::Presenters::UsersPresenter
        end

        desc 'Get all retired users'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort User::SORT_ORDERS
        get 'retired' do
           team = Team.find(params[:team_id]) || error!('team_id not supplied', 500)
          error!("Team #{team_id} API not enabled", 404) unless team.api?
          query = team.users.retired
          users = paginate_and_sort_by_cursor(query, default_sort_order: '-elo')
          present users, with: Api::Presenters::UsersPresenter
        end

        desc 'Get a user by user name.'
        params do
          requires :user_name, type: String, desc: 'User name.'
        end
        get 'user' do
          user = User.where(user_name: params[:user_name]).first || error!('User not found', 500)
          error!('User API not enabled', 404) unless user.team.api?
          present user, with: Api::Presenters::UserPresenter
        end

        desc 'Get a user.'
        params do
          requires :id, type: String, desc: 'User ID.'
        end
        get ':id' do
          user = User.find(params[:id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless user.team.api?
          present user, with: Api::Presenters::UserPresenter
        end

        desc 'Get all the users.'
        params do
          requires :team_id, type: String
          optional :captain, type: Boolean
          use :pagination
        end
        sort User::SORT_ORDERS
        get do
          team = Team.find(params[:team_id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless team.api?
          query = team.users
          query = query.captains if params[:captain]
          users = paginate_and_sort_by_cursor(query, default_sort_order: '-elo')
          present users, with: Api::Presenters::UsersPresenter
        end
      end
    end
  end
end
