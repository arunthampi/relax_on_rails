# README

This is a sample Slack Bot Application using Rails and [Relax](http://relax.zerobotlabs.com). Relax powers bot platforms such as [Nestor](https://v2.asknestor.me) and [Dunstin](https://dunstin.com).

## Setup

* Install `postgresql` && `redis`
* Run `cp .env-example .env`
* Create a new [Slack Application](https://api.slack.com/applications/new). **Remember**: To Setup a *Bot User* for the application and set a name for the bot.
* Get the Client ID and the Secret from the Slack Application and replace `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET` in `.env` with the client ID and secret respectively.
* Download and install [relax](https://github.com/zerobotlabs/relax) in your path (make sure the `relax` binary is available in your `$PATH`).
* Run `rake db:create db:migrate`
* Run `./script/server`
* Go to `localhost:5000` in your browser

## Configuring the way the Bot respond to messages

Right now, the bot sends a random greeting when it encounters the string `hello`. To change this behavior goto `config/initializers/relax.rb` and change the way bot responds to messages.

## Acknowledgements

This project is brought to you by the creators of [Nestor](https://v2.asknestor.me) &ndash; the programmable Slack Bot Platform.
