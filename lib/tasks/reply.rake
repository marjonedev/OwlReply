namespace :reply do
  desc "This will generate replies."
  task :do => :environment do
    #ARGV.each { |a| task a.to_sym do ; end }
    ReplyMaker::Replier.start_checking(force: ARGV[1].nil?)
  end
  task :reset => :environment do
    ReplyMaker::Replier.reset
  end
  desc "This will reset every account's error status"
  task :reset_error => :environment do
    ReplyMaker::Replier.reset_account_error
  end
end

