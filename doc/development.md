- [Setup] (#setup)
  - [Configure the google api] (#configure-the-google-api)
  - [What do you need?] (#what-do-you-need?)
  - [Configure the access app `sec_config.yml`] (#configure-the-access-app-sec_configyml)
  - [Import data from services] (#import-data-from-services)
  - [Configure DataGuru gem] (#configure-dataguru-gem)
  - [Configure access] (#configure-access)
  - [Setting up permissions] (#setting-up-permissions)
- [Adding / editing users] (#adding--editing-users)

## Setup

### Configure the google
Enable the following APIs:

- Groups Settings API
- Admin SDK
- Google+ API

### What do you need?

First of all, clone repositories mentioned below:

```
git git@github.com:netguru/access-permissions-sample.git permissions
git clone git@github.com:netguru/access.git
git clone git@github.com:netguru/data_guru-api.git
```

The last one is the internal project which use `data_guru` gem to change yml files into JSON ones and serves them. You need a something like data_guru API for Access.
Don’t forget about adding yourself to permissions in order to get an access.

### Configure the access app `sec_config.yml`
Sec-config is the file which override `config.yml`. In that file, you should have most of the configuration of the access app.

### Import data from services
Before you start using the access app, you first need to create a `permissions` repo. We created a feature to help you to import the data from services used by your organization configured in your `sec_config.yml`

```yaml
your_environment:
  features:
    generate_permissions: true
```

After enabling this feature, you can go to the main page and generate necessary files. The files will reside in your rails root directory at `tmp/new_permissions` dir ready to be copied to your `permissions` repo.

#### Github Teams
To import GitHub data from Github API to permissions directory, you just need click button 'Generate GitHub teams' on the main page of the access app. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir` in subdirectory `/github_teams`.

Since it has created the GitHub teams yml files, you can push them to your permissions repository on GitHub.

#### Google Groups
To import google data from Google API to permissions directory, you just need click button 'Generate google groups' on the main page of the access app. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir` in subdirectory `/google_groups`.

Since it has created the google groups yml files, you can push them to your permissions repository on GitHub.

#### Users
To import users data from Google API and Github API to permissions directory you just need click button 'Generate users' on the main page of the access app. Files will be saved in the directory specified in `sec_config.yml` in `AppConfig.permissions_repo.checkout_dir` in subdirectory `/users`.

Since it has created the users yml files, you can push them to your permissions repository on GitHub.

### Configure DataGuru gem
To make DataGuru gem work properly, you have to set up DataGuru-API first:

https://github.com/netguru/data_guru-api

In DataGuru-API you should set `git_repo_url` to your permissions repo URL. See [sec_config.yml](https://github.com/netguru/access/blob/master/config/sec_config.yml.sample#L6-L8), it requires replacement with your data.

Then you need to specify `api-url` and `access_token` in your `sec_config.yml` :

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
It is important because it presents where a repository is with permissions and you don’t need to store them at GitHub, locally is also a good approach, especially for developing environment.

Start DataGuru-API server on a port different than Access app, for example:

```
$ pwd
~/data_guru-api
$ bin/rails s -p 4200
```

### Configure access
Ask about `sec_config.yml` and don't forget about filling path to repository correctly. Also, it could be a path to the local repository on your computer.
Next, you need be Admin at your organization at GitHub to run Access app.

After it, you can run `bin/rails server` and check it at `http://localhost:3000`. If everything goes well, you should be able to see a page with permissions. If not, there could be problems with `data_guru` API.

### Setting up permissions
Permissions is a repository where we store information about privileges are saved as `yml` files. You should be allowed to create your own teams and users as well.

## Adding / editing users
Before you add team to google group or GitHub team you have to first create a data file for this user:

- define new user data file in 'users' directory named 'first_name.last_name.yml'
- add users name to the file
- add users GitHub handle to the file

Sample user file: https://github.com/netguru/access-permissions-sample/blob/master/users/jane.doe.yml
