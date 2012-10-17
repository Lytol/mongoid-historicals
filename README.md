Mongoid Historicals
===================

Record a snapshot of current values to reference later as historical values.


Installation
------------

Add to your Gemfile

    gem 'mongoid-historicals', :require => 'mongoid/historicals'


Usage
-----

Here is an example of how to track the week-to-week score for the players in my fictional MMORPGFPS:

    class Player
      include Mongoid::Document
      include Mongoid::Historicals

      field :username, type: String
      field :score,    type: Integer

      historicals :score, :max => 52, :frequency => :weekly
    end

In a cron task, I could run the following every Sunday before midnight:

    Player.all.each do |player|
      player.record!
    end

Then, I could show each player's historical score like this:

    <h2>Your Current Score: <%= @player.score %></h2>
    <p>Your Score Last Week: <%= @player.historical(:score, 1.week.ago) %> / Difference: <%= @player.historical_difference(:score, 1.week.ago) %></p>

