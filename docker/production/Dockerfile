FROM quay.io/netguru/ng-ruby:2.2.3

RUN /opt/passenger/install
RUN /opt/node/install

ENV APP_HOME /var/www/app
ENV RAILS_ENV=production
ENV REDIS_URL=redis://redis:6379/0


# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --jobs=8 --retry=3 --without development test --deployment

ADD . $APP_HOME/
ADD docker/production/entrypoint.sh /entrypoint.sh

ADD docker/production/service/sidekiq /etc/service/sidekiq/run

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/my_init"]
