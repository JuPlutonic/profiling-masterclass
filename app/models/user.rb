class User < ApplicationRecord
  # attr_reader :attributes, :sessions
  has_many :sessions, dependent: :delete_all

  #   def initialize(attributes = {})
  # super
  # @attributes = attributes
  # @sessions = @attributes&.[](sessions) || {}
  # end
end
