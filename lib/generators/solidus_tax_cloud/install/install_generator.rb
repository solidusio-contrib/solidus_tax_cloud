# frozen_string_literal: true

module SolidusTaxCloud
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false

      argument :file_name, type: :string, desc: 'rails app_path', default: '.'
      source_root File.expand_path('../templates', __dir__)

      def copy_initializer_file
        template 'ca-bundle.crt', "#{file_name}/lib/ca-bundle.crt"
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_tax_cloud'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Metrics/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
