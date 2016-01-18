require 'spec_helper'

describe Team do
  describe 'validations' do
    subject { create :team }

    it { should validate_presence_of :name    }
    it { should validate_presence_of :url     }
    it { should validate_presence_of :uid     }

    it { should validate_uniqueness_of :uid   }

    it { should allow_value('http://example.com').for(:url) }
    it { should_not allow_value('http://localhost').for(:url) }
  end

  describe 'associations' do
    it { should have_many :team_memberships }
    it { should have_many(:members).through(:team_memberships) }
    it { should have_one :bot }
  end
end
