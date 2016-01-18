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

  describe '#import_users!' do
    let!(:team)               { create :team }
    let!(:bot)                { create :bot, token: 'bot_token', team: team }
    let!(:slack)              { double('slack') }

    let!(:identify_user_job)  { double('identify_user_job') }

    before do
      allow(identify_user_job).to receive(:perform)
      allow(Slack).to receive(:new).with(bot.token).and_return(slack)
      allow(slack).to receive(:call).with('users.list', :get).and_return(
        {
          "ok" => true,
          "members" => [
            {
              'id' => 'UDEADBEEF1',
              'name' => 'sjobs',
              'tz' => 'Los Angeles',
              'tz_label' => 'Pacific Daylight Time',
              'tz_offset' => '-25200',
              'profile' => {
                'email' => 'sjobs@apple.com',
                'first_name' => 'Steve',
                'last_name' => 'Jobs',
                'real_name' => 'Steve Jobs',
              },
              'is_admin' => true,
              'is_owner' => true,
              'is_restricted' => false
            },
            {
              'id' => 'UDEADBEEF2',
              'name' => 'elonmusk',
              'profile' => {
                'email' => 'elon@apple.com',
                'first_name' => 'Elon',
                'last_name' => 'Musk',
                'real_name' => 'Elon Musk',
              },
              'tz' => 'Los Angeles',
              'tz_label' => 'Pacific Daylight Time',
              'tz_offset' => '-25200',
              'is_admin' => false,
              'is_owner' => false,
              'is_restricted' => true
            },
            {
              'id' => 'UDEADBEEF3',
              'name' => 'timcook',
              'profile' => {
                'email' => 'tim@apple.com',
                'first_name' => 'Tim',
                'last_name' => 'Cook',
                'real_name' => 'Tim Cook',
              },
              'tz' => 'Los Angeles',
              'tz_label' => 'Pacific Daylight Time',
              'tz_offset' => '-25200',
              'is_admin' => true,
              'is_owner' => false,
              'is_restricted' => false,
              'deleted' => true
            },
          ]
        }
      )
    end

    context 'none of the users exist' do
      it 'should add three users' do
        expect {
          team.import_users!
          team.reload
        }.to change(team.members, :count).by(3)

        members = team.members.order("id ASC")

        user1 = members[0]
        tm1 = TeamMembership.where(user_id: user1.id, team_id: team.id).first

        expect(user1.timezone).to eql 'Los Angeles'
        expect(user1.timezone_description).to eql 'Pacific Daylight Time'
        expect(user1.timezone_offset).to eql -25200
        expect(user1.nickname).to eql 'sjobs'
        expect(user1.email).to eql 'sjobs@apple.com'
        expect(user1.first_name).to eql 'Steve'
        expect(user1.last_name).to eql 'Jobs'
        expect(user1.full_name).to eql 'Steve Jobs'
        expect(tm1).to_not be_nil
        expect(tm1.membership_type).to eql 'owner'
        expect(tm1.user_uid).to eql 'UDEADBEEF1'

        user2 = members[1]
        tm2 = TeamMembership.where(user_id: user2.id, team_id: team.id).first

        expect(user2.timezone).to eql 'Los Angeles'
        expect(user2.timezone_description).to eql 'Pacific Daylight Time'
        expect(user2.timezone_offset).to eql -25200
        expect(user2.nickname).to eql 'elonmusk'
        expect(user2.email).to eql 'elon@apple.com'
        expect(user2.first_name).to eql 'Elon'
        expect(user2.last_name).to eql 'Musk'
        expect(user2.full_name).to eql 'Elon Musk'
        expect(tm2).to_not be_nil
        expect(tm2.membership_type).to eql 'guest'
        expect(tm2.user_uid).to eql 'UDEADBEEF2'

        user3 = members[2]
        tm3 = TeamMembership.where(user_id: user3.id, team_id: team.id).first

        expect(user3.timezone).to eql 'Los Angeles'
        expect(user3.timezone_description).to eql 'Pacific Daylight Time'
        expect(user3.timezone_offset).to eql -25200
        expect(user3.nickname).to eql 'timcook'
        expect(user3.email).to eql 'tim@apple.com'
        expect(user3.first_name).to eql 'Tim'
        expect(user3.last_name).to eql 'Cook'
        expect(user3.full_name).to eql 'Tim Cook'
        expect(tm3).to_not be_nil
        expect(tm3.membership_type).to eql 'deleted'
        expect(tm3.user_uid).to eql 'UDEADBEEF3'
      end
    end

    context 'some of the users exist' do
      let!(:existing_user) { create :user, email: 'elonmusk@apple.com' }
      let!(:existing_tm)   { create :team_membership, team: team, user: existing_user, membership_type: 'member', user_uid: 'UDEADBEEF2' }

      it 'should only add the new users and update info on existing users' do
        expect {
          team.import_users!
          team.reload
        }.to change(team.members, :count).by(2)

        members = team.members.order("id ASC")

        user1 = members[0]
        tm1 = TeamMembership.where(user_id: user1.id, team_id: team.id).first
        expect(user1.timezone).to eql 'Los Angeles'
        expect(user1.timezone_description).to eql 'Pacific Daylight Time'
        expect(user1.timezone_offset).to eql -25200
        expect(user1.nickname).to eql 'elonmusk'
        # It should not change the email address
        expect(user1.email).to eql 'elonmusk@apple.com'
        expect(user1.first_name).to eql 'Elon'
        expect(user1.last_name).to eql 'Musk'
        expect(user1.full_name).to eql 'Elon Musk'
        expect(tm1).to_not be_nil
        # It should change the membership type
        expect(tm1.membership_type).to eql 'guest'
        expect(tm1.user_uid).to eql 'UDEADBEEF2'

        user2 = members[1]
        tm2 = TeamMembership.where(user_id: user2.id, team_id: team.id).first

        expect(user2.timezone).to eql 'Los Angeles'
        expect(user2.timezone_description).to eql 'Pacific Daylight Time'
        expect(user2.timezone_offset).to eql -25200
        expect(user2.nickname).to eql 'sjobs'
        expect(user2.email).to eql 'sjobs@apple.com'
        expect(user2.first_name).to eql 'Steve'
        expect(user2.last_name).to eql 'Jobs'
        expect(user2.full_name).to eql 'Steve Jobs'
        expect(tm2).to_not be_nil
        expect(tm2.membership_type).to eql 'owner'
        expect(tm2.user_uid).to eql 'UDEADBEEF1'

        user3 = members[2]
        tm3 = TeamMembership.where(user_id: user3.id, team_id: team.id).first

        expect(user3.timezone).to eql 'Los Angeles'
        expect(user3.timezone_description).to eql 'Pacific Daylight Time'
        expect(user3.timezone_offset).to eql -25200
        expect(user3.nickname).to eql 'timcook'
        expect(user3.email).to eql 'tim@apple.com'
        expect(user3.first_name).to eql 'Tim'
        expect(user3.last_name).to eql 'Cook'
        expect(user3.full_name).to eql 'Tim Cook'
        expect(tm3).to_not be_nil
        expect(tm3.membership_type).to eql 'deleted'
        expect(tm3.user_uid).to eql 'UDEADBEEF3'
      end
    end
  end
end
