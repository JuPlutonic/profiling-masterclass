Rails.application.routes.draw do
# FIXME: send parameters to get route
  get 'report(/:start_date/:finish_date)', action: :report, controller: 'report'
end
