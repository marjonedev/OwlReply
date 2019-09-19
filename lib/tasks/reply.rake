namespace :reply do
  desc "This will generate replies."
  task :do => :environment do
    ReplyMaker::Replier.start_checking
  end
  task :reset => :environment do
    ReplyMaker::Replier.reset
  end
end

