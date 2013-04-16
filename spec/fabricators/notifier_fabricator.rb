# encoding: utf-8

Fabricator(:notifier, class_name: "Notifier") do
  label 'arbitrary_label'
  log_path '/var/log/syslog'
  regexp 'warn'
  exclude 'exclude'
  email_from 'spec@haikanko.com'
end
