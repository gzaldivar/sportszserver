web: bundle exec thin start -R config.ru -e $RAILS_ENV -p $PORT
resque: env TERM_CHILD=1 bundle exec rake resque:work
