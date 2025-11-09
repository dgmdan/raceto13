# MLB Runs Pool Game

[![Ruby on Rails CI](https://github.com/dgmdan/raceto13/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/dgmdan/raceto13/actions/workflows/rubyonrails.yml)

This is a simple office pool game based on MLB scores. The basic rules are:

* Players sign up and buy one or more entries
* At the beginning of the MLB season, each entry is randomly assigned a team
* The first team with final run scores matching every number from 0 to 13 wins

The more complete set of rules are in `entries/index.html.erb`

### Command reference

* Use `rails import_data:teams` to create Team records for all MLB teams by scraping ESPN data.
* Use `rails game_state:assign_teams` to randomly assign MLB teams to unassigned Entries.
* Use `rails import_data:advance` to scrape ESPN for scores and check for winners. Date range starts on the first day without a Game or the first day of the 2015 season, if there are no games. Date range ends one day before the current date.
* Use `rails game_state:reset` to erase all scores. Users and entries are retained but team assignment and winner info fields are cleared.
* Use `rails game_state:assign_notifications` to create NotificationTypeUser records so all users get email alerts on new hits and when the league ends.
* `rails test` to run the test suite.

### TODO

* Live scores of in progress games on the scoreboard
