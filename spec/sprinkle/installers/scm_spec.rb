require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::SCM do
  include Sprinkle::Deployment

  before do
    @source = 'http://github.com/crafterm/sprinkle/trunk'

    @deployment = deployment do
      delivery :capistrano      
      scm 'http://github.com/crafterm/sprinkle/trunk' do
        prefix   '/usr'
        builds   '/usr/builds'
      end
    end

    @installer = create_scm @source, '1.2.3' do
      prefix   '/usr/local'
      builds   '/usr/local/builds'
    end

    @installer.defaults(@deployment)
  end

  def create_scm(source, version = nil, &block)
    @package = mock(Sprinkle::Package, :name => 'package', :version => version)
    Sprinkle::Installers::SCM.new(@package, source, &block)
  end

  describe 'when created' do

    it 'should accept a source url to install' do
      @installer.source.should == @source
    end

  end

  describe 'when checking out from source without scm option' do

    it 'should checkout from the source via svn by default' do   
      (@installer.send(:download)).should eql(
        [
         "svn checkout #{@source} /usr/local/builds/sprinkle-1.2.3"
        ]
      )
    end

    after do
      @installer.send :install_sequence
    end

  end
  
  describe 'when checking out from source with scm option' do

    it 'should checkout from the source via git if specified as scm' do
      @source = 'git://github.com/crafterm/sprinkle.git'  
      @installer = create_scm @source, '2.3.1' do
        scm 'git'
        prefix   '/usr/local'
        builds   '/usr/local/builds'  
      end

      @installer.defaults(@deployment)      
      
      (@installer.send(:download)).should eql(
        [
         "git clone #{@source} /usr/local/builds/sprinkle.git-2.3.1"
        ]
      )
    end
    
    it 'should checkout from the source via svn if specified as scm' do
      @source = 'http://github.com/crafterm/sprinkle/trunk'
      @installer = create_scm @source, '3.2.1' do
        scm 'svn'
        prefix   '/usr/local'
        builds   '/usr/local/builds'  
      end

      @installer.defaults(@deployment)      
      
      (@installer.send(:download)).should eql(
        [
         "svn checkout #{@source} /usr/local/builds/sprinkle-3.2.1"
        ]
      )
    end  

    after do
      @installer.send :install_sequence
    end

  end

  describe 'install sequence' do

    it 'should prepare, then checkout, then configure, then build, then install' do
      %w( prepare download configure build install ).each do |stage|
        @installer.should_receive(stage).ordered.and_return([])
      end
    end

    after do
      @installer.send :install_sequence
    end

  end

end
