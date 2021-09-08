Rails.application.routes.draw do
  get 'report(/:start_date/:finish_date)', action: :report, controller: 'report'
end
