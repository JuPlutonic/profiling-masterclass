class User < ApplicationRecord
  attr_reader :user_attribs, :sessions

  def initialize(user_attribs = {}, sessions = {})
    @user_attribs = user_attribs[:user_attribs]
    @sessions = user_attribs[:sessions]
  end
end
