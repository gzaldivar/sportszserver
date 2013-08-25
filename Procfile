web: bundle exec thin start -R config.ru -e $RAILS_ENV -p $PORT
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake resque:work
