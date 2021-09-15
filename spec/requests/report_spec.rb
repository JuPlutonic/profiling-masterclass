require 'rails_helper'

RSpec.describe '/report', type: :request do
  before do
    Rails.application.load_seed
    # or load with lib/report_builder_N.rb
  end

  describe 'GET /' do
    it 'renders a successful response' do
      get root_path
      expect(response).to be_successful
    end
  end
end
