# Access app

This application introduces "push-style" management of permissions for github and google apps (todo).  The goal is to store yaml files that define our github teams and users, and apply the permissions once some changes are pushed to those files.

This makes managing permissions very easy, and also makes it possible for your users to propose changes (via commit to permissions repo or pull request).

Sample permissions directory looks like this: https://github.com/netguru/access-permissions-sample

## Table of contents

- [Setup] (#setup)
- [Github] (#github)
  - [Adding new user] (#adding-new-user)
  - [Adding / editing github teams] (#adding--editing-github-teams)
  - [User naming within permissions repo] (#user-naming-within-permissions-repo)
  - [Adding new repositories] (#adding-new-repositories)
  - [Deleting users] (#deleting-users)
  - [Deleting teams] (#deleting-teams)
- [Rollbar] (#rollbar)
- [Google apps] (#google-apps)
  - [Adding groups] (#adding-groups)
  - [Adding group aliases] (#adding-group-aliases)
  - [Group settings] (#group-settings)
    - [Privacy] (#privacy)
    - [Archive] (#archive)
    - [Default config] (#default-config)
  - [Removing groups] (#removing-groups)
  - [Creating google accounts] (#creating-google-accounts)
  - [Service Account authorization] (#service-account-authorization)
- [Flow for applying the changes.] (#flow-for-applying-the-changes)
- [FAQ] (#faq)

## Setup

Please, see at [development documentation](https://github.com/netguru/access/blob/master/doc/development.md).

## Github

#### Adding new user
In order to create new github user, create a file in `members` directory.
The file should be named using this pattern `first_name.last_name.yml`.
More details, and some example [here](https://github.com/netguru/access-permissions-sample/blob/master/members/netguru/readme.md)

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


## Rollbar

We need organization token in order to perform teams management with Rollbar.
You can find the token
[here](https://rollbar.com/settings/accounts/YOUR-ORGANIZATION/access_tokens/)

## Adding teams

In order to add new rollbar team, please create a file in `rollbar_teams/`
directory. It should look like this:

```yml
---
name: cool name for a foo project
members:
  - john.doe
  - jane.doe
projects:
  - foo-project
```

## Google apps

#### Adding groups

Adding google group is very similar to adding github team - just create group file in `google_groups` directory and sync your changes. The file name will be the name of the group.

You can find sample group here: https://github.com/netguru/access-permissions-sample/blob/master/google_groups/sample-group.yml

Remember that anywhere within the app, users are referenced by their data file name and not emails or logins.

#### Adding group aliases

Special `aliases` key in group file allows you to controll group aliases.

See example here: https://github.com/netguru/access-permissions-sample/blob/master/google_groups/sample-group.yml#L6

#### Group settings

##### Privacy

Define the level of privacy for your groups. There are two settings:

```yaml
private: true
```

or

```yaml
private: false
```

when a google group is set to open (`private: false`) it means that:

  - all in domain can view this group
  - it is shown in a group directory

when a google group is set to closed (`private: true`) it means that:

  - only members of the group can view it
  - it is hidden from a group directory

##### Archive

Define if messages in a group should be archived

```yaml
archive: true/false
```

##### Default config

you can define the default behavior of privacy and archive by creating a file in your permissions repo `google_defaults.yml`.

```yaml
group:
  private: false
  archive: false
```

#### Removing groups

To remove google group just remove it's file from the google groups folder. The application should display "stranded" groups on diff screen. You can confirm the deletion there.

#### Creating google accounts

To create a new google account you need to add new yaml file with user. The file should be created inside of directory named the same like company from `config.yml` (e.g. `permissions/users/company_name/firstname.lastname.yml`).

Filename will be an account login (e.g. if your main_domain is `company_name.com` created email will look like `firstname.lastname@company_name.com`).

Remember to include in the yml file following attributes:
- `name:` which should be a full name of the person
- `github` which is github login of the person (if you use that service)

You can find sample user file here:
https://github.com/netguru/access-permissions-sample/blob/master/users/user_group/jane.kowalski.yml

Since the file is added you will see it under header 'Missing user's account' in google show diff `google/show_diff` action. Then to create missing accounts just click button 'Create accounts'.
The application will:
- create missing accounts,
- generate 2step codes,
- reset password (user will be asked to change it while first login),
- will post gmail filters
- and finally will send email to email specified in `AppConfig.office_email` containing details necessary to login, 2step codes and short instruction (from `AppConfig.google.email.account_using_instruction`).

#### Service Account authorization

You might want to authorize more people to apply changes to some google groups but you are reluctant to provide them with admin rights. In that case you can enable a feature `use_service_account: true` to use a Service Account as an authorization strategy.

Then you set who and what can sync: (in sec_config.yml)

1. what google groups can manage sync:

```yaml
google:
  managers:
    groups:
      - 'support'
      - 'managers'
      - 'founders'
```

2. what group emails can they manage (these are turned into regexp later on):

```yaml
google:
  groups:
  - .*-supported@.*
  - special-group-managed-by-support.*
```

Now you also need to activate a service account on google and configure it properly:

- go to console.google.com
- go to credentials - and create a new client id http://screencast.com/t/PjRw88ySI
- copy service account email to sec_config.yml (google.service_account_email)
- copy p12 file to server
- set p12_key_path and secret in sec config
- go to admin.google.com
- go to security/show more/advanced/Manage API client access
- http://screencast.com/t/5gIEyb0vtl
- setup groups whitelists (which groups can be managed by the support?)

The way how *service accounts* work is that it authenticates through p12 key and then can use google API as another user. So to have this working we need to create a google account with admin rights that the service account could use. You set that account in `sec_config.yml` as a `supporter_email` key.

## Flow for applying the changes.

Once you are done editing / creating the files you should apply new permissions:

- push the changes to permissions directory
- have somebody from owners team visit the access app and review the changes
- once the review it’s done she/he can press “Confirm changes” link
- access app will pull the permissions repo and apply the changes to github.

A good idea is to use `rake notify` in your CI to notify the owners that changes to the permissions repo were made.


## FAQ

#### 1. `Not Authorized to access this resource/api` while trying to run show_diff on google groups.
- check `access/config/config`
 google:
   main_domain: netguru.org
if domain is really used in setup project.
- check `access/config/sec_config` google: client_id: and client_secret: if equals settings from console.developers.google.com, tabs: Apis -> Credentials -> OAuth.
- check if you try to login with the proper user. You must login with administrator of the account.
- remember to restart server and clean session after each attempt to fix from above steps.

#### 2. Request rate is higher than expected error (or Backend Error) (google api show diff)
- to mitigate this problem you should change quotas - per-user limit:
  - go to `https://console.google.com` and and find the app you're using for access
  - go to APIs/EnabledAPIs/Groups Settings API/Quotas
  - edit `Per-user limit` setting, and rise the request limit to something more reasonable (eg. 1000)
  - do the same for Admin SDK
