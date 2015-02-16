# Access app

This application introduces "push-style" management of permissions for github and google apps (todo).  The goal is to store yaml files that define our github teams and users, and apply the permissions once some changes are pushed to those files.

This makes managing permissions very easy, and also makes it possible for your users to propose changes (via commit to permissions repo or pull request).

Sample permissions directory looks like this: https://github.com/netguru/access-permissions-sample

### Adding / editing users
Before you add team to google group or github team you have to first create a data file for this user:

- define new user data file in 'users' directory named 'first_name.last_name.yml'
- add users name to the file
- add users github handle to the file

Sample user file: https://github.com/netguru/access-permissions-sample/blob/master/users/jane.doe.yml

## Github

#### Adding / editing github teams

Team data files include:
- team name
- team permission level
- team members list

Sample team file: https://github.com/netguru/access-permissions-sample/blob/master/github_teams/team-a.yml

Once such file is pushed to the permissions repository a team-a will be created with jane and john as members. All members are going to be given push access to ‘sample-repo’.

#### User naming within permissions repo

Users in teams files are referenced by their data file name (first_name.last_name) instead of being referenced by github handles. This makes it’s easy to read the team file and actually see who has access where without confusion - this is also very useful from security perspective in larger organizations.

Remember you have to first add user to users directory before adding him to a team

#### Adding new repositories

Adding a repository that does not exist in to the team file will create an empty repository with that name.

#### Deleting users
- remove john.doe from every group file and github teams file
- remove john.doe file from users directory

#### Deleting teams
Delete team file from repository and go to github/diff screen. It should display teams that do not have their files in permissions repository any more. You can confirm and delete them by pressing delete button under 'stranded' teams.

## Google apps

#### Adding groups

Adding google group is very similar to adding github team - just create group file in `google_groups` directory and sync your changes. The file name will be the name of the group.

You can find sample group here: https://github.com/netguru/access-permissions-sample/blob/master/google_groups/sample-group.yml

Remember that anywhere within the app, users are referenced by their data file name and not emails or logins.

#### Adding group aliases

Special `aliases` key in group file allows you to controll group aliases.

See example here: https://github.com/netguru/access-permissions-sample/blob/master/google_groups/sample-group.yml#L6

#### Removing groups

To remove google group just remove it's file from the google groups folder. The application should display "stranded" groups on diff screen. You can confirm the deletion there.

## Flow for applying the changes.

Once you are done editing / creating the files you should apply new permissions:

- push the changes to permissions directory
- have somebody from owners team visit the access app and review the changes
- once the review it’s done she/he can press “Confirm changes” link
- access app will pull the permissions repo and apply the changes to github.

A good idea is to use `rake notify` in your CI to notify the owners that changes to the permissions repo were made.
