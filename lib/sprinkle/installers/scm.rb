module Sprinkle
  module Installers
    # = SCM Package Installer
    #
    # The scm package installer installs software from an source control management tool.
    # As it inherits from the 'source' package installer, it also handles configuring, building, 
    # and installing the software. 
    # What differs is the download procedure:
    #
    # == Configuration Options
    #
    # The source installer has many configuration options:
    # * <b>scm</b> - The prefix directory that is configured to (#one of svn (default), git, hg, bzr, darcs,cvs).
    # * <b>builds</b> - The directory the code under scm is extracted to to configure and install
    # * <b>archives</b> - Not used. Everything is checked out directly to the 'builds' directory    
    # 
    # == Example Usage
    #
    # First, a simple package, no configuration:
    #
    #   package :magic_beans do
    #     source 'http://svn.magicbeansland.com/latest/trunk'
    #   end
    #
    # Second, specifying a different scm tool and a different build directory:
    #
    #   package :magic_beans do
    #     source 'http://magicbeansland.com/latest.git' do
    #       scm    'git'
    #       builds    '/tmp/builds'
    #     end
    #   end
    #
    # All other 'source' installer options apply.
    class SCM < Source

      protected

        def install_sequence #:nodoc:
          prepare + download + configure + build + install
        end
        
        def prepare_commands #:nodoc:
          raise 'No installation area defined' unless @options[:prefix]
          raise 'No build area defined' unless @options[:builds]
          raise 'No package version defined' unless @package.version

          [ "mkdir -p #{@options[:prefix]}",
            "mkdir -p #{@options[:builds]}" ]
        end        

        def download_commands #:nodoc:
          @options[:scm] = 'svn' unless @options[:scm]
          case @options[:scm]
            when /git$/
              ["git clone #{@source} #{build_dir}"]
            when /svn$/
              ["svn checkout #{@source} #{build_dir}"]
            when /hg$/
              ["hg clone #{@source} #{build_dir}"]
            when /bzr$/
              ["bzr checkout #{@source} #{build_dir}"]
            when /darcs$/
              ["darcs get #{@source} #{build_dir}"]
            when /cvs$/
              ["cvs checkout #{@source} #{build_dir}"]
            else
              raise "Unknown scm: #{build_dir}"
          end
        end

      private

        def base_dir #:nodoc:
          paths = @source.split('/')
          case paths.last
            when /trunk/
              "#{paths[-2]}-#{@package.version}"
            else
              "#{paths.last}-#{@package.version}"
          end
        end
        
    end
  end
end
