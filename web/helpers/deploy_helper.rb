# encoding: utf-8

module Web
  module DeployHelper
    ### href
    def agent_href(host, opts = {})
      query = opts.dup.tap {|q| q['host'] = host }.to_query
      "/web/pipework/agent.conf?#{query}"
    end

    def worker_href(hostport, opts = {})
      query = opts.dup.tap {|q| q['hostport'] = hostport }.to_query
      "/web/pipework/worker.conf?#{query}"
    end

    %w[ all all_agent all_worker ].each do |kind|
      define_method("#{kind}_href") do |label, opts = {}|
        query = opts.dup.tap {|q| q['label'] = label }.to_query
        "/web/pipework/#{kind}?#{query}"
      end
    end

    ### status_label
    %w[ agent worker ].each do |kind|
      define_method("#{kind}_status_label") do |feature, hostname|
        deployed = feature.send("#{kind}_deployed?", hostname)
        label = feature.enabled? ?
          (feature.deployable? ? (deployed ? 'label-success' : 'label-warning') : 'label-default') :
          (deployed ? 'label-inverse' : 'label-important' )
        "<span class='label #{label}'>&nbsp;</span>"
      end
    end

    %w[ all all_agent all_worker ].each do |kind|
      define_method("#{kind}_status_label") do |feature|
        deployed = feature.send("#{kind}_deployed?")
        label = feature.enabled? ?
          (feature.deployable? ? (deployed ? 'label-success' : 'label-warning') : 'label-default') :
          (deployed ? 'label-inverse' : 'label-important' )
        "<span class='label #{label}'>&nbsp;</span>"
      end
    end

    ### deploy_button
    %w[ agent worker all all_agent all_worker ].each do |kind|
      define_method("#{kind}_deploy_button") do |arg, deployable|
        href = send("#{kind}_href", arg, :exec => 'on')
        return <<-HTML
        <a href="#{h href}" class="btn" role="button" data-method="post" data-confirm="true" #{disabled_if(!deployable)}>
          <i class="icon-fire"></i>Deploy
        </a>
        HTML
      end
    end

    ### dryrun_button
    %w[ agent worker all all_agent all_worker ].each do |kind|
      define_method("#{kind}_dryrun_button") do |arg, deployable|
        href = send("#{kind}_href", arg)
        return <<-HTML
        <a href="#{h href}" class="btn" role="button" data-method="post" #{disabled_if(!deployable)}>
          <i class="icon-leaf"></i>Dry Run
        </a>
        HTML
      end
    end
  end
end
