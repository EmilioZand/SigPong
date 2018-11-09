module Api
  module Presenters
    module ReportsPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer
      include Api::Presenters::PaginatedPresenter

      collection :results, extend: ReportPresenter, as: :reports, embedded: true
    end
  end
end
