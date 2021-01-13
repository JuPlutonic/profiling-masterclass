Rails.application.routes.draw do
  get '/report', action: :report, controller: 'report', defaults: { start_date: '2015-01-01', finish_date: '2021-01-02' }
end
