class User < ApplicationRecord
  validates :email, 'valid_email_2/email': { strict_mx: true }, on: :create
  # attr_reader :attributes, :sessions
  has_many :sessions, dependent: :delete_all

  # def initialize(attributes = {})
  #   super
  #   @attributes = attributes
  #   @sessions = @attributes&.[](sessions) || {}
  # end
end
