namespace :users_and_sessions do
  desc "Create users and sessions"
  task create: :environment do
    return puts 'Not available for Production' if Rails.env.production?

    Benchmarks::DbFileIo.new
  end
end
