# encoding: utf-8

module Promo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Creates the models to the file'

      def self.source_root
        @_promo_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_migration_files
        time = Time.now.strftime("%Y%m%d%H%M%S").to_i
        template '1_create_promo_promocode.rb', File.join('db', 'migrate', "#{time}_create_promo_promocode.rb")
        template '2_create_promo_history.rb', File.join('db', 'migrate', "#{time+1}_create_promo_history.rb")
      end

    end
  end
end
