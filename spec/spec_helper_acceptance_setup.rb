hosts.each do |h|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  scp_to h, File.join(proj_root, 'spec/fixtures/make-dummy-cert'), '/tmp/make-dummy-cert'
  on h, '/tmp/make-dummy-cert /tmp/host /tmp/bestman /tmp/rsv /tmp/http'
end
