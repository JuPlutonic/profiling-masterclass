# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'faker'

# TODO: Less magic numbers
###########################
# Methods used in load_seed
def form_user
  first_name, mid, last_name = Faker::Name.name_with_middle.split
  first_name = mid if first_name.end_with?('.')
  username = Faker::Internet.username(
    specifier: "#{first_name} #{last_name}",
    separators: %w(. _ -)
  )
  { 'first_name' => first_name, 'last_name' => last_name,
     'email' => Faker::Internet.email(name: username),
     'age' => [*21..90].sample
  }
end

def form_session
  { 'browser' => select_browser,
    'duration' => [*1..330].sample,
    'date' => Faker::Date.backward(days: 2553),
    'country' => Faker::Address.country }
end

def select_browser
  value = ['Internet Explorer', 'FireFox', 'Chrome', 'Safari'].sample
  case value
  when 'Internet Explorer'
    value + ' ' + [*6..11, *20..90].sample.to_s
  # when 'Microsoft Edge'
  #   value + ' ' + [*20..90].sample.to_s
  when 'FireFox'
    value + ' ' + [*24..87].sample.to_s
  when 'Chrome'
    value + ' ' + [*30..89].sample.to_s
  when 'Safari'
    value + ' ' + [*6..11].sample.to_s
  else
    value
  end
end

# Seeds 100_000 new users and their into the DB
def load_seed
  collect_sessions = []
  100_000.times do
    [*1..5].sample.times do
      collect_sessions << form_session
    end
    collect_sessions = collect_sessions.first if collect_sessions.count == 1
    u = User.new(attributes: form_user, sessions: collect_sessions)
    u.attributes.merge!(u.attributes[:attributes])
    u.attributes.except!(:attributes)
    u.save
  end
end

load_seed
