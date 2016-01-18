require 'spec_helper'

describe Bot do
  describe 'validations' do
    it { should validate_presence_of :team_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :token   }
    it { should validate_uniqueness_of :token }
  end

  describe 'associations' do
    it { should belong_to :team     }
    it { should belong_to :creator  }
  end
end
