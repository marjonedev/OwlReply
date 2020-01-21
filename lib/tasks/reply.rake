namespace :reply do
  desc "This will generate replies."
  task :do => :environment do
    ReplyMaker::Replier.start_checking
  end
  task :reset => :environment do
    ReplyMaker::Replier.reset
  end
  desc "This will reset every account's error status"
  task :reset_error => :environment do
    ReplyMaker::Replier.reset_account_error
  end
end

