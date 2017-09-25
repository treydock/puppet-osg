require 'spec_helper_acceptance'

describe 'osg::lcmaps_voms class:' do
  context "with parameters defined" do
    node = only_host_with_role(hosts, 'ce')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
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

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::osg_lcmaps_voms", node

    describe file('/etc/grid-security/voms-mapfile'), :node => node do
      its(:content) { should match /"\/GLOW\/\*" glow/ }
      its(:content) { should match /"\/GLOW\/chtc\/\*" glow1/ }
      its(:content) { should match /"\/GLOW\/Role=htpc\/\*" glow1/ }
    end
    describe file('/etc/grid-security/grid-mapfile'), :node => node do
      its(:content) { should match /"\/fooDN" foo/ }
      its(:content) { should match /"\/foo" foobar/ }
      its(:content) { should match /"\/bar" foobar/ }
    end
    describe file('/etc/grid-security/ban-voms-mapfile'), :node => node do
      its(:content) { should match /"\/cms\/Role=production\/\*"/ }
    end
    describe file('/etc/grid-security/ban-mapfile'), :node => node do
      its(:content) { should match /\/foo\/baz/ }
    end

  end
end
