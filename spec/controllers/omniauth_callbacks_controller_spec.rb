require 'spec_helper'

describe OmniauthCallbacksController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET :slack' do
    def do_request
      get :slack
    end

    let!(:omniauth_hash) {
      {
        "provider" => "slack",
        "uid" => "U0304SBK4",
        "info" => {
          "name" => "Arun Thampi",
          "email" => "arun@mixcel.io",
          "nickname" => "arun",
          "first_name" => "Arun",
          "last_name" => "Thampi",
          "description" => nil,
          "image" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_192.jpg",
          "team"=>"Mixcel",
          "user" => "arun",
          "team_id" => "T0304SBJU",
          "user_id" => "U0304SBK4"
        },
        "credentials" => {
          "token" => "deadbeef",
          "expires" => false
        },
        "extra" => {
          "bot_info" => {
            "bot_access_token" => "xoxb-cafedead",
            "bot_user_id" => "UDEADBEEF1"
          },
          "raw_info" => {
            "ok" => true,
            "url" => "https://mixcel.slack.com/",
            "team" => "Mixcel",
            "user" => "arun",
            "team_id" => "T0304SBJU",
            "user_id" => "U0304SBK4"
          },
          "user_info" => {
            "ok" =>true,
            "user" =>{
              "id" => "U0304SBK4",
              "name" => "arun",
              "deleted" => false,
              "status" => nil,
              "color" => "9f69e7",
              "real_name" => "Arun Thampi",
              "tz" => "America/Los_Angeles",
              "tz_label" => "Pacific Daylight Time",
              "tz_offset" => -25200,
              "profile" => {
                "first_name" => "Arun",
                "last_name" => "Thampi",
                "image_24" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_24.jpg",
                "image_32" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_32.jpg",
                "image_48"=>"https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_48.jpg",
                "image_72"=>"https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_72.jpg",
                "image_192"=>"https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_192.jpg",
                "image_original"=>"https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_original.jpg",
                "skype"=>"arun_thampi",
                "real_name"=>"Arun Thampi",
                "real_name_normalized"=>"Arun Thampi",
                "email"=>"arun@mixcel.io"
              },
              "is_admin"=>true,
              "is_owner"=>true,
              "is_primary_owner"=>true,
              "is_restricted"=>false,
              "is_ultra_restricted"=>false,
              "is_bot"=>false,
              "has_files"=>true,
              "has_2fa"=>false
            }
          }
        }
      }
    }

    before do
      allow(ImportUsersForTeamJob).to receive(:perform_async)
    end

    context 'when user is signed in' do
      let!(:user) { create :user }

      before do
        request.env.merge!('omniauth.auth' => omniauth_hash)
        sign_in user
      end

      def do_request
        get :slack
      end

      context 'when a matching identity is not found (user is signed in to a different team with the same uid)' do
        let!(:identity) {
          create(:identity, provider: 'slack',
                 uid: omniauth_hash['uid'],
                 team_uid: 'TDEADBEEF',
                 token: 'deadbeef',
                 user: user)
        }

        it 'creates a new identity record' do
          expect {
            do_request
          }.to change { user.reload.identities.count }.by(1)

          expect(user.identities.last.provider).to eq('slack')
          expect(user.identities.last.uid).to eq(omniauth_hash['uid'])
          expect(user.identities.last.team_uid).to eq(omniauth_hash['info']['team_id'])
          expect(user.identities.last.token).to eq 'deadbeef'
        end
      end

      context 'when a matching identity is found' do
        let!(:identity) {
          create(:identity, provider: 'slack',
                 uid: omniauth_hash['uid'],
                 team_uid: omniauth_hash['info']['team_id'],
                 token: 'deadbeef',
                 user: user)
        }

        it 'does not create new identity' do
          expect {
            do_request
          }.to_not change { user.reload.identities.count }
        end

        it "should redirect to the team path" do
          do_request
          expect(response).to redirect_to team_url('T0304SBJU')
        end

        it 'updates identity object with new token' do
          do_request
          expect(identity.reload.token).to eql omniauth_hash['credentials']['token']
        end

        it 'should not update the email of the user' do
          expect {
            do_request
            user.reload
          }.to_not change(user, :email)
        end

        it 'should update the user with the Omniauth data received' do
          do_request
          user.reload

          expect(user.nickname).to eql 'arun'
          expect(user.first_name).to eql 'Arun'
          expect(user.last_name).to eql 'Thampi'
          expect(user.full_name).to eql 'Arun Thampi'

          expect(user.signed_in_via_oauth).to be_truthy

          team = user.teams.first

          expect(team.name).to eql 'Mixcel'
          expect(team.uid).to eql 'T0304SBJU'
          expect(team.url).to eql 'https://mixcel.slack.com/'

          tm = user.team_memberships.first
          expect(tm.membership_type).to eql 'owner'

          expect(user.image_url).to eql 'https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_192.jpg'
          expect(user.timezone).to eql 'America/Los_Angeles'
          expect(user.timezone_description).to eql 'Pacific Daylight Time'
          expect(user.timezone_offset).to eql -25200
        end

        it "creates a new bot" do
          do_request

          u = controller.current_user
          team = u.teams.first
          bot = team.bot

          expect(bot).to_not be_nil
          expect(bot.creator).to eql u
          expect(bot.token).to eql 'xoxb-cafedead'
        end
      end
    end

    context 'when user is not signed in' do
      before do
        request.env.merge!('omniauth.auth' => omniauth_hash)
      end

      context 'when there is an existing user identity with the same uid and provider' do
        let!(:identity)       { create :identity, uid: omniauth_hash['uid'], provider: 'slack', team_uid: omniauth_hash['info']['team_id'] }
        let!(:user)           { identity.user }

        it "logs the user in" do
          do_request
          expect(controller).to be_signed_in
          expect(controller.current_user).to eq(user)
        end

        it "redirects to the team path" do
          do_request
          expect(response).to redirect_to team_url('T0304SBJU')
        end

        # This user already exists in the database and is most likely
        # creating a new team from the same Nestor user account
        # (but probably a different email address on Slack)
        # So we don't update email addresses
        it "should not change the user's email address" do
          expect {
            do_request
            user.reload
          }.to_not change(user, :email)
        end

        it "updates the identity data" do
          do_request
          identity.reload
          expect(identity.token).to eq(omniauth_hash['credentials']['token'])
        end

        it "updates the information for that user based on the Omniauth callback data" do
          do_request
          user.reload

          expect(user.nickname).to eql 'arun'
          expect(user.first_name).to eql 'Arun'
          expect(user.last_name).to eql 'Thampi'
          expect(user.full_name).to eql 'Arun Thampi'

          expect(user.signed_in_via_oauth).to be_truthy

          team = user.teams.first

          expect(team.name).to eql 'Mixcel'
          expect(team.uid).to eql 'T0304SBJU'
          expect(team.url).to eql 'https://mixcel.slack.com/'

          tm = user.team_memberships.first
          expect(tm.membership_type).to eql 'owner'

          expect(user.image_url).to eql 'https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_192.jpg'
          expect(user.timezone).to eql 'America/Los_Angeles'
          expect(user.timezone_description).to eql 'Pacific Daylight Time'
          expect(user.timezone_offset).to eql -25200
        end

        it "creates a new bot" do
          do_request

          u = controller.current_user
          team = u.teams.first
          bot = team.bot

          expect(bot).to_not be_nil
          expect(bot.creator).to eql u
          expect(bot.token).to eql 'xoxb-cafedead'
        end
      end

      # This is the case when a user has been imported into the system
      # (from a team)
      context "when there is a user with the given provider_uid and no identity" do
        let!(:team) { create :team, name: 'Mixcel', uid: 'T0304SBJU', url: 'https://mixcel.slack.com/' }
        let!(:user) { create :user }
        let!(:tm)   { create :team_membership, team: team, user: user, user_uid: 'U0304SBK4' }

        it "logs the user in" do
          do_request
          expect(controller).to be_signed_in
          expect(controller.current_user).to eq(user)
        end

        it "redirects to the team path" do
          do_request
          expect(response).to redirect_to team_url('T0304SBJU')
        end

        it "updates the identity data" do
          do_request
          identity = user.identities.where(provider: omniauth_hash['provider'], uid: omniauth_hash['uid']).first

          expect(identity).to_not be_nil
          expect(identity.token).to eq(omniauth_hash['credentials']['token'])
        end

        it 'should not update the email of the user' do
          expect {
            do_request
            user.reload
          }.to_not change(user, :email)
        end

        it "updates the information for that user based on the Omniauth callback data" do
          do_request
          user.reload

          expect(user.nickname).to eql 'arun'
          expect(user.first_name).to eql 'Arun'
          expect(user.last_name).to eql 'Thampi'
          expect(user.full_name).to eql 'Arun Thampi'
          expect(user.signed_in_via_oauth).to be_truthy

          team = user.teams.first

          expect(team.name).to eql 'Mixcel'
          expect(team.uid).to eql 'T0304SBJU'
          expect(team.url).to eql 'https://mixcel.slack.com/'

          tm = user.team_memberships.first
          expect(tm.membership_type).to eql 'owner'

          expect(user.image_url).to eql 'https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-05-11/4836202382_65573aedd51b9b423a87_192.jpg'
          expect(user.timezone).to eql 'America/Los_Angeles'
          expect(user.timezone_description).to eql 'Pacific Daylight Time'
          expect(user.timezone_offset).to eql -25200
        end

        it "creates a new bot" do
          do_request

          u = controller.current_user
          team = u.teams.first
          bot = team.bot

          expect(bot).to_not be_nil
          expect(bot.creator).to eql u
          expect(bot.token).to eql 'xoxb-cafedead'
        end
      end
    end
  end
end
