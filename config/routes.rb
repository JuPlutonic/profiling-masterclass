Rails.application.routes.draw do
# FIXME: send parameters to get route
  get '/report', action: :report, controller: 'report', defaults: { start_date: '2015-01-01', finish_date: '2021-02-16' }
end
