- [Setup] (#setup)
  - [Configure the Google API] (#configure-the-google-api)
  - [What do you need?] (#what-do-you-need?)
  - [Configure the Access App `sec_config.yml`] (#configure-the-access-app-sec_configyml)
  - [Import data from services] (#import-data-from-services)
  - [Configure DataGuru gem] (#configure-dataguru-gem)
  - [Configure access] (#configure-access)
  - [Setting up permissions] (#setting-up-permissions)
- [Adding / editing users] (#adding--editing-users)

## Setup

### Configure Google
Enable the following APIs:

- Groups Settings API
- Admin SDK
- Google+ API

### What do you need?

First of all, clone repositories mentioned below:

```
git clone git@github.com:netguru/access-permissions-sample.git permissions
git clone git@github.com:netguru/access.git
git clone git@github.com:netguru/data_guru-api.git
```

The last one is the internal project that uses `data_guru` gem to change YML files into JSON ones and serves them. You need something like data_guru API for access.
Don’t forget about adding yourself to permissions in order to have access.

### Configure the Access App `sec_config.yml`
`sec_config.yml` is the file that overrides `config.yml`. In this file, you should have most of the configuration for the Access App.

### Import data from services
Before you start using Access App, you first need to create a `permissions` repo. We created a feature to help you import the data from services used by your organization configured in your `sec_config.yml`.

```yaml
your_environment:
  features:
    generate_permissions: true
```

After enabling this feature, you can go to the main page and generate necessary files. The files will reside in your rails root directory in `tmp/new_permissions` dir ready to be copied to your `permissions` repo.

#### Github Teams
To import GitHub data from Github API to permissions directory, you just need to click button 'Generate GitHub teams' on the main page of the Access App. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir`, in subdirectory `/github_teams`.

Since it has created the GitHub teams YML files, you can push them to your permissions repository on GitHub.

#### Google Groups
To import google data from Google API to permissions directory, you just need to click button 'Generate google groups' on the main page of the Access App. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir`, in subdirectory `/google_groups`.

Since it has created the Google groups YML files, you can push them to your permissions repository on GitHub.

#### Users
To import users data from Google API and Github API to permissions directory, you just need to click button 'Generate users' on the main page of the Access App. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir`, in subdirectory `/users`.

Since it has created the users YML files, you can push them to your permissions repository on GitHub.

### Configure DataGuru gem
To make DataGuru gem work properly, you have to set up DataGuru-API first:

https://github.com/netguru/data_guru-api

In DataGuru-API you should set `git_repo_url` to your permissions repo URL. See [sec_config.yml](https://github.com/netguru/access/blob/master/config/sec_config.yml.sample#L6-L8), it requires replacement with your data.

Then you need to specify `api-url` and `access_token` in your `sec_config.yml`:

```
dataguru:
    api_url: 'URL of DataGuru-API'
    access_token: 'access token from DataGuru-API'
```

Ask about `config.yml`, especially don’t forget about modifying these lines:

```yml
defaults: &defaults
  git_repo_url: 'file:///path_to_repository/permissions/'
  git_repo_temp_dir: 'tmp/permissions'
  ...
```
It is important because it points to the repository with permissions and you don’t need to store them on GitHub. Storing locally is a good approach as well, especially for development environment.

Start DataGuru-API server on a port different than Access App, for example:

```
$ pwd
~/data_guru-api
$ bin/rails s -p 4200
```

### Configure access
Ask about `sec_config.yml` and don't forget about filling path to repository correctly. Also, it could be a path to the local repository on your computer.
Next, you need be Admin at your organization at GitHub to run Access App.

After it, you can run `bin/rails server` and check it at `http://localhost:3000`. If everything goes well, you should be able to see a page with permissions. If not, there could be problems with `data_guru` API.

### Setting up permissions
Permissions is a repository in which we store information about privileges, which are saved as YML files. You should be allowed to create your own teams and users as well.

## Adding / editing users
Before you add a team to Google group or GitHub team, you have to first create a data file for this user:

- define new user data file in `users` directory named `first_name.last_name.yml`
- add the user's name to the file
- add the user's GitHub handle to the file

Sample user file: https://github.com/netguru/access-permissions-sample/blob/master/users/jane.doe.yml
