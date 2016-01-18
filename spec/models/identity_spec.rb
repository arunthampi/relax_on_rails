require 'spec_helper'

describe Identity do
  it { should belong_to :user }

  describe 'validations' do
    before { expect(create(:identity)).to be_valid }

    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
    it { should validate_presence_of :token }
    it { should validate_presence_of :team_uid }
  end
end
