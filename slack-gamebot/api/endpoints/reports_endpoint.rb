module Api
  module Endpoints
    class ReportsEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :reports do
        desc 'Get a report.'
        params do
          requires :id, type: String, desc: 'Report ID.'
        end
        get ':id' do
          report = Report.find(params[:id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless report.team.api?
          present report, with: Api::Presenters::ReportPresenter
        end

        desc 'Get all outstanding reports.'
        params do
          requires :team_id, type: String
          use :pagination
        end
        sort Report::SORT_ORDERS
        get do
          team = Team.find(params[:team_id]) || error!('team_id not supplied', 500)
          error!("Team #{team_id} API not enabled", 404) unless team.api?
          reports = paginate_and_sort_by_cursor(team.reports.proposed, default_sort_order: '-_id')
          present reports, with: Api::Presenters::ReportsPresenter
        end

        desc 'Create a report'
        params do
          requires :team_id, type: String
          requires :reporter_ids, type: Array
          requires :opponent_ids, type: Array
          requires :scores, type: Array
          optional :reporter_team, type: String
          optional :opponent_team, type: String
        end
        post do
          team = Team.find(params[:team_id]) || error!('Not Found', 404)
          error!('Not Found', 404) unless team.api?
          teammates = []
          opponents = []
          params[:reporter_ids].each do |r|
            user = User.find(r) || error!('Not Found', 404)
            teammates << user
          end

          params[:opponent_ids].each do |r|
            user = User.find(r) || error!('Not Found', 404)
            opponents << user
          end

          error!('Not Found', 404) unless team.api?
          report = Report.create_from_teammates_and_opponents!(team, 'webUI', teammates, opponents, params[:scores], params[:reporter_team], params[:opponent_team])
          present report, with: Api::Presenters::ReportPresenter
        end
      end
    end
  end
end
