# encoding: utf-8

module Web
  ROUTES = {
    '/'               => Web::FrontController,
    '/web'            => Web::FrontController,
    '/web/notifier'   => Web::NotifierController,
    '/web/visualizer' => Web::VisualizerController,
    '/web/irc'        => Web::IrcController,
    '/web/email'      => Web::EmailController,
    '/web/role'       => Web::RoleController,
    '/web/pipework'   => Web::PipeworkController,
  }
end
