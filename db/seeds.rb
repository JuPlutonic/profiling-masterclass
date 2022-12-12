# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'faker'

class CreateTestUsers
  AGE_OF_MAJORITY = 18

  def call
    find_or_create
  end

  private

  def find_or_create
    users_create_or_update.each do |item|
      u = User.find_or_initialize_by({email: item[:email]})
      u.first_name = item[:first_name]
      u.last_name = item[:last_name]
      u.age = item[:age]
      u.sessions = item[:sessions]
      u.save!
    end
  end

  def users_create_or_update
    @users_create_or_update ||= [
      {
        last_name: 'Cira',
        first_name: 'Leida',
        email: 'n.eliseeva@digital.gov.ru',
        age: 0,
        sessions: [Session.new( { browser: 'Safari 29', duration: 87, date: '2016-10-23', country: 'se' } ),
                   Session.new( { browser: 'Firefox 12', duration: 118, date: '2017-02-27', country: 'se' } ),
                   Session.new( { browser: 'Internet Explorer 28', duration: 31, date: '2017-03-28', country: 'se' } ),
                   Session.new( { browser: 'Internet Explorer 28', duration: 109, date: '2016-09-15', country: 'se' } ),
                   Session.new( { browser: 'Safari 39', duration: 104, date: '2017-09-27', country: 'se' } ),
                   Session.new( { browser: 'Internet Explorer 35', duration: 6, date: '2016-09-01', country: 'se' } )]
      },
      {
        last_name: 'Katrina',
        first_name: 'Palmer',
        email: 'a.sadykova@digital.gov.ru',
        age: 65,
        sessions: [Session.new( { browser: 'Safari 17', duration: 12, date: '2016-10-21', country: 'se' } ),
                   Session.new( { browser: 'Firefox 32', duration: 3, date: '2016-12-20', country: 'se' } ),
                   Session.new( { browser: 'Chrome 6', duration: 59, date: '2016-11-11', country: 'se' } ),
                   Session.new( { browser: 'Internet Explorer 10', duration: 28, date: '2017-04-29', country: 'se' } ),
                   Session.new( { browser: 'Chrome 13', duration: 116, date: '2016-12-28', country: 'se' } )]
      },
      {
        last_name: 'Santos',
        first_name: 'Gregory',
        email: 'moscow1@digital.gov.ru',
        age: 86,
        sessions: [Session.new( { browser: 'Chrome 35', duration: 6, date: '2018-09-21', country: 'se' } ),
                   Session.new( { browser: 'Safari 49', duration: 85, date: '2017-05-22', country: 'se' } ),
                   Session.new( { browser: 'Firefox 47', duration: 17, date: '2018-02-02', country: 'se' } ),
                   Session.new( { browser: 'Chrome 20', duration: 84, date: '2016-11-25', country: 'se' } )]
      }
    ].freeze
  end
end

###########################
# Methods used in load_seed
#
# def form_user
#   first_name, mid, last_name = Faker::Name.name_with_middle.split
#   first_name = mid if first_name.end_with?('.')
#   username = Faker::Internet.username(
#     specifier: "#{first_name} #{last_name}",
#     separators: %w(. _ -)
#   )
#   { 'first_name' => first_name, 'last_name' => last_name,
#     'email' => Faker::Internet.email(name: username),
#     'age' => [*21..90].sample
#   }
# end

# def form_session
#   { 'browser' => select_browser,
#     'duration' => [*1..330].sample,
#     'date' => Faker::Date.backward(days: 2553),
#     'country' => Faker::Address.country }
# end

def select_browser
  value = ['Internet Explorer ', 'FireFox ', 'Chrome ', 'Safari '].sample
  case value
  when 'Internet Explorer ';'Safari '
    value + [*6..11].sample.to_s
  when 'Microsoft Edge '
    value + [*20..90].sample.to_s
  when 'FireFox '
    value + [*24..90].sample.to_s
  when 'Chrome '
    value + [*30..92].sample.to_s
  else
    value.strip
  end
end

# Seeds 100_000 new users and their into the DB
#
# def load_seed
#   collect_sessions = []
#   100_000.times do
#     [*1..5].sample.times do
#       collect_sessions << form_session
#     end
#     collect_sessions = collect_sessions.first if collect_sessions.count == 1
#     u = User.new(attributes: form_user, sessions: collect_sessions)
#     u.attributes.merge!(u.attributes[:attributes])
#     u.attributes.except!(:attributes)
#     u.save
#   end
# end

# def form_session(current_user)
#   Session.new(
#     browser: select_browser,
#     duration: [*1..330].sample,
#     date: Faker::Date.backward(days: 2553),
#     country: Faker::Address.country,
#     user: current_user
#   ).call
# end

# Seeds 100_000 new users and their into the DB
# def load_seed
#   users = (1..100_000).map do
#     current_user = User
#       .new(first_name: Faker::Name.first_name,
#           last_name: Faker::Name.last_name,
#           email: Faker::Internet.email,
#           age: [*AGE_OF_MAJORITY..100].sample)
#       .call
#     [*1..5].sample.times { form_session(current_user) }
#   end
# end

# load_seed
CreateTestUsers.new.call
