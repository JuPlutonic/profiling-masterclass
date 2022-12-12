require 'rails_helper'

RSpec.describe '/report', type: :request do
  before do
    Rails.application.load_seed
    # or load with app/lib/N_report_builder.rb
  end

  describe 'GET /' do
    it 'renders a successful response' do
      get root_path
      expect(response).to be_successful
    end
  end
end
