# # lib/sequel_auth/generator/install_generator.rb
# module SequelAuth
#   module Generator
#     class InstallGenerator
#       def initialize(app_root)
#         @app_root = app_root
#       end

#       def install
#         create_directories
#         copy_views
#         copy_migrations
#         inject_helpers
#       end

#       private

#       def create_directories
#         FileUtils.mkdir_p(File.join(@app_root, 'views/auth'))
#         FileUtils.mkdir_p(File.join(@app_root, 'db/migrations'))
#       end

#       def copy_views
#         template_dir = File.expand_path('../../../templates', __dir__)

#         # Copy auth views
#         FileUtils.cp_r(
#           File.join(template_dir, 'views/auth'),
#           File.join(@app_root, 'views/')
#         )

#         # Copy layout if it doesn't exist
#         layout_destination = File.join(@app_root, 'views/layout.erb')
#         return if File.exist?(layout_destination)

#         FileUtils.cp(
#           File.join(template_dir, 'views/layout.erb'),
#           layout_destination
#         )
#       end

#       def copy_migrations
#         template_dir = File.expand_path('../../../templates', __dir__)

#         # Generate timestamp for migration
#         timestamp = Time.now.strftime('%Y%m%d%H%M%S')

#         FileUtils.cp(
#           File.join(template_dir, 'migrations/create_users.rb'),
#           File.join(@app_root, "db/migrations/#{timestamp}_create_users.rb")
#         )
#       end

#       def inject_helpers
#         # For Sinatra apps
#         app_file = File.join(@app_root, 'app.rb')
#         return unless File.exist?(app_file)

#         content = File.read(app_file)
#         return if content.include?('SequelAuth::Helpers')

#         inject_into_file(app_file, sinatra_setup_code)
#       end

#       def sinatra_setup_code
#         <<-RUBY

#   enable :sessions
#   helpers SequelAuth::Helpers
#   register SequelAuth::Routes
#         RUBY
#       end

#       def inject_into_file(file_path, content)
#         lines = File.readlines(file_path)
#         class_line_index = lines.find_index { |line| line.match(/class.*<.*Sinatra::Base/) }

#         return unless class_line_index

#         lines.insert(class_line_index + 1, content)
#         File.write(file_path, lines.join)
#       end
#     end
#   end
# end
module SequelAuth
  module Generator
    class InstallGenerator
      def initialize(app_root)
        @app_root = app_root
      end

      def install
        create_directories
        copy_views
        copy_migrations
        inject_helpers
      end

      private

      def create_directories
        FileUtils.mkdir_p(File.join(@app_root, 'views/auth'))
        FileUtils.mkdir_p(File.join(@app_root, 'db/migrations'))
      end

      def copy_views
        template_dir = File.expand_path('../../../templates', __dir__)
        FileUtils.cp_r(
          File.join(template_dir, 'views/auth'),
          File.join(@app_root, 'views/')
        )
      end

      def copy_migrations
        template_dir = File.expand_path('../../../templates', __dir__)
        timestamp = Time.now.strftime('%Y%m%d%H%M%S')
        FileUtils.cp(
          File.join(template_dir, 'migrations/create_users.rb'),
          File.join(@app_root, "db/migrations/#{timestamp}_create_users.rb")
        )
      end

      def inject_helpers
        app_file = File.join(@app_root, 'app.rb')
        return unless File.exist?(app_file)

        content = File.read(app_file)
        return if content.include?('SequelAuth::Helpers')

        inject_into_file(app_file)
      end

      def inject_into_file(file_path)
        lines = File.readlines(file_path)
        class_line_index = lines.find_index { |line| line.match(/class.*<.*Roda/) }
        return unless class_line_index

        lines.insert(class_line_index + 1, roda_setup_code)
        File.write(file_path, lines.join)
      end

      def roda_setup_code
        <<-RUBY
  plugin :sessions
  include SequelAuth::Helpers
        RUBY
      end
    end
  end
end
