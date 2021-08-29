RSpec.describe 'Rails.application' do
  describe '#load_seed' do
    subject { Rails.application.load_seed }

    it do
      expect { subject }.to change(User, :count).by(3) # by(100_000)
        .and change(Session, :count).by_at_least(15) # (100_000)
    end
  end
end
