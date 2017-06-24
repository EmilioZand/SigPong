require 'sidekiq'

class ConfirmReport
  include Sidekiq::Worker

  def perform(report)
    report.confirm!(report.created_by)
  end
end