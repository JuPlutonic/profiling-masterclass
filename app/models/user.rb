class User < ApplicationRecord
  attr_reader :attributes, :sessions
  has_many :sessions, dependent: :delete_all

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end
