- [Setup](#setup)
  - [Configure the Google API](#configure-the-google-api)
  - [What do you need?](#what-do-you-need?)
  - [Configure the Access App `sec_config.yml`](#configure-the-access-app-sec_configyml)
  - [Import data from services](#import-data-from-services)
  - [Configure DataGuru gem](#configure-dataguru-gem)
  - [Configure access](#configure-access)
  - [Setting up permissions](#setting-up-permissions)]
  - [Setting Jira SDK](#setup-jira-sdk)
- [Adding / editing users](#adding--editing-users)

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

### Setting up Jira SDK
To run a Jira instance locally you first need to download the SDK. Homebrew is required to do this:
* `brew tap atlassian/tap`
* `brew install atlassian/tap/atlassian-plugin-sdk`
Confirm that everything is working by running `atlas-version`

If any of the above commands don't work - consult this [link](https://developer.atlassian.com/docs/getting-started/set-up-the-atlassian-plugin-sdk-and-build-a-project/install-the-atlassian-sdk-on-a-linux-or-mac-system).

Next run the following command to run Jira:
* `mkdir -p ~/jira && cd $_`
* `atlas-standalone-run --product jira --context-path '/'`

The script will now download all the required packages (it may take a while).
It is very important to include `--context-path '/'` - without it, the gems used for integration won't work, because jira will be mounted at `/jira` instead the root of the url.

After Jira is compiled and deployed to Tomcat, you will see a url in the console. Open it in your browser, log in as `admin:admin` and update Jira Base Url when prompted by a popup (if the popup won't appear, then go to `Administration > System > Click 'Edit' button` and remove the `/jira` part).

Next you need to generate a public/private key-pair. Run the following:
```
cd config
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -sha1 -keyout jira_private_key.pem -out jira_x509_certificate.pem
openssl x509 -pubkey -noout -in jira_x509_certificate.pem > jira_public_key.key
cd ..
```

And update the path to you private key (`jira_private_key.pem`) in `sec_config.yml@jira/private_key_path`.

Now you can create an Application Link in order to obtain OAuth keys:
* visit `Administration > Applications > Applications links`
* type in `localhost:3000` in the input and press `Create new link`
* a popup will appear, press `Continue`
* another form will appear, fill it as following:
  * `Application Name` - name of your OAuth app, eg. accessguru
  * `Application Type` - generic
  * `Service Provider Name` - name of provider (not important), eg. accessguru
  * `Consumer key` - OAuth consumer key, eg. access-jira-test (write it down somewhere)
  * `Shared secret` - generate one using `openssl rand -base64 32`
  * `Request Token URL` - your Jira Base Url + `/plugins/servlet/oauth/request-token`
  * `Access token URL` - your Jira Base Url + `/plugins/servlet/oauth/access-token`
  * `Authorize URL` - your Jira Base Url + `/plugins/servlet/oauth/authorize`
  * `Create incoming link` - check it
* fill out the next form:
  * `Consumer key` - same as in the previous form
  * `Consumer name` - same as `Application Name`
  * `Public key` - copy & paste the public key you generated earlier - `cat jira_public_key.key | pbcopy`
* Press `Continue`

After this, your Application link is ready. Now fill in the missing data in `sec_config.yml`:
* `site` - your Jira Base Url
* `consumer_key` - the key you've entered into the form

You are ready to launch Access and try to sign in via Jira, go to `localhost:3000/auth/jira` and do the OAuth dance.

## Adding / editing users
Before you add a team to Google group or GitHub team, you have to first create a data file for this user:

- define new user data file in `users` directory named `first_name.last_name.yml`
- add the user's name to the file
- add the user's GitHub handle to the file

Sample user file: https://github.com/netguru/access-permissions-sample/blob/master/users/jane.doe.yml
