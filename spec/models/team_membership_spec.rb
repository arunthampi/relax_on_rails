require 'spec_helper'

describe TeamMembership do
  describe 'validations' do
    it { should validate_presence_of :user_id         }
    it { should validate_presence_of :team_id         }
    it { should validate_presence_of :user_uid        }
    it { should validate_presence_of :membership_type }

    it { should allow_value('owner').for(:membership_type) }
    it { should allow_value('admin').for(:membership_type) }
    it { should allow_value('guest').for(:membership_type) }
    it { should allow_value('member').for(:membership_type) }
    it { should allow_value('deleted').for(:membership_type) }
    it { should_not allow_value('hello').for(:membership_type) }
  end

  describe 'associations' do
    it { should belong_to :team }
    it { should belong_to :user }
  end
end
