namespace :heroku do
  namespace :scheduler do
    desc "This task is called by the Heroku scheduler add-on"
    task :confirm_reports => :environment do
      logger.info "Confirming outstanding reports..."
      Report.confirm_outstanding_reports
    end
  end
end