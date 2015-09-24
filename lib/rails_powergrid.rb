module RailsPowergrid
  class << self
    def gem_path
      File.expand_path("../..", __FILE__)
    end

    def stylesheets_path
      File.join assets_path, 'stylesheets'
    end

    def fonts_path
      File.join assets_path, 'fonts'
    end

    def images_path
      File.join assets_path, 'images'
    end

    def javascripts_path
      File.join assets_path, 'javascripts'
    end

    def assets_path
      @assets_path ||= File.join gem_path, 'app/assets'
    end

    def _require file
      require File.join gem_path, "lib", "rails_powergrid", file
    end

    #def setup_autoload!
    #  %w(app/helpers app/views).each do |dir|
    #    path = File.join(File.expand_path('../..', __FILE__), dir )
    #    $LOAD_PATH << path
    #    ActiveSupport::Dependencies.autoload_paths << path
    #    ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    #  end
    #end

    def load!
      require 'react-rails'
      require 'sprockets-coffee-react'

      require 'sass-rails'
      require 'compass-rails'

      require 'font-awesome-rails'

      require 'rails_powergrid/column'
      require 'rails_powergrid/grid'
      require 'rails_powergrid/controller'
      require 'rails_powergrid/railtie'
      require 'rails_powergrid/ext/routing'
      require 'rails_powergrid/predicator/base'

      if Gem::Specification.find_all_by_name('rubyXL').any?
        #Rails.logger.info "RailsPowergrid Module Excel Activated"
        require 'rails_powergrid/excel'
      end

      Sprockets.append_path(stylesheets_path)
      Sprockets.append_path(fonts_path)
      Sprockets.append_path(javascripts_path)
      Sprockets.append_path(images_path)
    end

    def grid name, opts={}
      RailsPowergrid::Grid.load(name).to_javascript(opts)
    end
  end
end

RailsPowergrid::load!