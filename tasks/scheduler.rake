desc "This task is called by the Heroku scheduler add-on"
task :confirm_reports => :environment do
  puts "Confirming outstanding reports..."
  Report.confirm_outstanding_reports
  puts "done."
end