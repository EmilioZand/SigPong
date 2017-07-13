require 'sucker_punch'

class ConfirmReportJob
  include SuckerPunch::Job

  def perform(report)
    if report.proposed?
      report.confirm!(report.opponents.first)
    end
  end
end
