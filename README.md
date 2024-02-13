> [!CAUTION]
> This project is currently unmaintained and has missing dependency upgrades, leaving the project with known vulnerabilities. We strictly advise against using this tool in a production environment before upgrading Ruby version, framework and other dependencies.

# TeamBuilder

TeamBuilder is an add-on application for MOOC platforms that aids in building teams for course work.

Depending on the settings for a course, participants will be asked a series of questions.
Once all participants have completed the survey (or time runs out), course admins can start building groups.
Based on the available data, groups can be built to be diverse or similar according to certain criteria.

Supported criteria include:

- timezone (always on),
- location,
- spoken language,
- gender,
- area of expertise, and others.

After the automatic team building, admins can review the results, and manually re-order teams.
Finally, a list of teams can be exported to CSV.
For each team, a group / learning room can be created on the course provider platform (if supported).

## Setup

### Requirements

- Ruby 2.x
- A PostgreSQL database
- Nodejs
- Yarn Package Manager

### Installation

```sh
bundle install
bundle exec rake db:create db:migrate
yarn install
```

The web server can be started with `bundle exec rails s` or, if installed, using Foreman: `foreman start`.

### Contribution Guidelines
Branches should start with your initials and contain the issue number aswell as a short title. (i.e. `jb/osap-880-button-to-cancel-application`)  
Try to keep commits "atomic". Each commit should provide value to the system and leave it in a working and functional state.
Bugfixes for previous commits should be squashed before merging. 
But only at the end of the development cycle to simplify collaboration on a branch by multiple developers.


## Architecture

TeamBuilder is a typical Ruby on Rails application.

For authentication, it uses the low-level [Warden gem](https://github.com/hassox/warden/).
This helped us in supporting authentication both trough LTI (for course users) and a password (for the platform admin).

## Platform integrations

This project is implemented to integrate deeply with the HPI MOOC platform, and directly uses its internal APIs. Visit https://open.hpi.de/pages/open_source to find out more about the source code of the platform (and other, related Open Source projects).
