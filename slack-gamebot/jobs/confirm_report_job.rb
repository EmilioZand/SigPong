require 'sucker_punch'

class ConfirmReportJob
  include SuckerPunch::Job

  def perform(report)
    if report.proposed?
      report.confirm!(report.created_by)
    end
  end
end
