# Access app

## Goal

This application introduces "push-style" management of permissions for github and google apps (todo).  The goal is to store yaml files that define our github teams and users, and apply the permissions once some changes are pushed to those files.

This makes managing access on github very easy, and also makes it possible for your users to propose changes (via commit to permissions repo or pull request).

Sample permissions directory looks like this: https://github.com/netguru/access-permissions-sample

### Managing users

When you are about to add new user to your organization, you should first define his data file. Data files are stored in permission repo in users directory and should be named following `first_name.last_name.yml` pattern. Here is a sample user file:
https://github.com/netguru/access-permissions-sample/blob/master/users/jane.doe.yml

### Adding new team to github

Team data files include:
- team name
- team permission level
- team members list

Sample team file looks like so: https://github.com/netguru/access-permissions-sample/blob/master/github_teams/team-a.yml

Once such file is pushed to the permissions repository a team-a will be created with jane and john as members. All members are going to be given push access to ‘sample-repo’.

### Note on users

Users in teams files are referenced by their data file name (first_name.last_name) instead of being referenced by github handles. This makes it’s easy to read the team file and actually see who has access where without confusion. Very useful from security perspective in larger organizations.

### Note on new repos

Adding a repository that does not exist in to the team file will create an empty repository with that name.


## Flow for applying the changes.

- push the changes to permissions directory
- have somebody from owners team visit the access app and review the changes
- once the review it’s done she/he can press “Confirm changes” link
- access app will pull the permissions repo and apply the changes to github.

A good idea is to use `rake notify` in your CI to notify the owners that changes to the permissions repo were made.
