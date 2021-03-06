require 'spec_helper_acceptance'

describe 'osg::lcmaps_voms class:' do
  node = find_at_most_one_host_with_role(hosts, 'agent')
  context 'with parameters defined' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'osg':
          auth_type => 'lcmaps_voms',
        }
        class { 'osg::lcmaps_voms':
          ban_voms => ['/cms/Role=production/*'],
          ban_users => ['/foo/baz'],
          vos => {
            'glow'  => '/GLOW/*',
            'glow1' => ['/GLOW/chtc/*', '/GLOW/Role=htpc/*'],
          },
          users => {
            foo    => '/fooDN',
            foobar => ['/foo', '/bar'],
          }
        }
      EOS

      apply_manifest_on(node, pp, catch_failures: true)
      apply_manifest_on(node, pp, catch_changes: true)
    end

    it_behaves_like 'osg::osg_lcmaps_voms', node

    describe file('/etc/grid-security/voms-mapfile'), node: node do
      its(:content) { is_expected.to include '"/GLOW/*" glow' }
      its(:content) { is_expected.to include '"/GLOW/chtc/*" glow1' }
      its(:content) { is_expected.to include '"/GLOW/Role=htpc/*" glow1' }
    end
    describe file('/etc/grid-security/grid-mapfile'), node: node do
      its(:content) { is_expected.to include '"/fooDN" foo' }
      its(:content) { is_expected.to include '"/foo" foobar' }
      its(:content) { is_expected.to include '"/bar" foobar' }
    end
    describe file('/etc/grid-security/ban-voms-mapfile'), node: node do
      its(:content) { is_expected.to include '"/cms/Role=production/*"' }
    end
    describe file('/etc/grid-security/ban-mapfile'), node: node do
      its(:content) { is_expected.to include '/foo/baz' }
    end
  end

  context 'osg-configure cleanup' do
    it 'deletes osg-configure packages to pass other tests' do
      # Cleanup the so osg-configure
      on node, 'yum remove -y osg-configure\*'
      on node, 'rm -f /etc/osg/config.d/99-local-site-settings.ini'
    end
  end
end
