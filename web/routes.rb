# encoding: utf-8

module Web
  ROUTES = {
    # Web browsers will GET the favicon.ico resource with every single request.
    # Without a dedicated route for it:
    '/favicon.ico' => proc { |env| [200, {'Content-Type' => 'plain/text'}, ['']] },
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
