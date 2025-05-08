require 'fastlane_core/ui/ui'

module Fastlane

	UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

	module Helper

		class AppDynamicsHelper

			DEFAULT_HOST = 'https://api.eum-appdynamics.com'
			DEFAULT_VERSION = 'v2'

			module Key
				API_ACCOUNT_NAME = :api_account_name
				API_HOST = :api_host
				API_LICENSE_KEY = :api_license_key
				API_VERSION = :api_version
				DSYM_PATH = :dsym_path
				DSYM_PATHS = :dsym_paths
				FAIL_ON_ERROR = :fail_on_error
				MAPPING_PATH = :mapping_path
				MAPPING_PATHS = :mapping_paths
				PACKAGE_NAME = :package_name
				VERSION_CODE = :version_code
			end

			def self.connection(params)
				require 'faraday'
				require 'faraday_middleware'

				host = params[Key::API_HOST]
				version = params[Key::API_VERSION]
				api_account_name = params[Key::API_ACCOUNT_NAME]
				api_license_key = params[Key::API_LICENSE_KEY]

				Faraday.new() do |builder|
					builder.request :basic_auth, api_account_name, api_license_key
					builder.use FaradayMiddleware::FollowRedirects
					builder.adapter :net_http
				end
			end

			def self.validate(params)
				error = params[:error]
				error_message = params[:error_message] || 'An AppDynamics error occurred'
				fail_on_error = params[:fail_on_error].to_s.casecmp('true').zero?

				unless error.nil?
					UI.user_error! "#{error_message}" if fail_on_error
				end
			end

			def self.upload_dsyms(params)
				connection = self.connection(params)
				host = params[Key::API_HOST]
				version = params[Key::API_VERSION]
				api_account_name = params[Key::API_ACCOUNT_NAME]

				# https://api.eum-appdynamics.com/v2/account/<EUM_Account_Name>/ios-dsym
				url = "#{host}/#{version}/account/#{api_account_name}/ios-dsym"

				dsym_path = params[Key::DSYM_PATH]
				dsym_paths = params[Key::DSYM_PATHS] || []
				dsym_paths << dsym_path unless dsym_path.nil?
				dsym_paths = dsym_paths.map { |path| File.absolute_path(path) }

				dsym_paths.each do |path|
					UI.user_error!("dSYM does not exist at path: #{path}") unless File.exist?(path)
				end

				dsym_paths.compact.uniq.map do |dsym|
					UI.message("Uploading dSYM: #{dsym}")

					error = nil

					begin
						response = connection.put(url) do |request|
							content_type = 'application/octet-stream'
							request.headers[:content_type] = content_type
							request.headers[:content_length] = File.size(dsym).to_s
							request.body = Faraday::UploadIO.new(dsym, content_type)
						end

						UI.success "Successfully uploaded dsym: #{response.status} - #{response.reason_phrase}" if response.success?
					rescue => e
						error = e
						UI.error(e)
					end

					self.validate(error: error, error_message: 'Error while trying to upload dsym', fail_on_error: params[Key::FAIL_ON_ERROR])
				end
			end

			def self.upload_mappings(params)
				connection = self.connection(params)
				host = params[Key::API_HOST]
				version = params[Key::API_VERSION]
				api_account_name = params[Key::API_ACCOUNT_NAME]
				package_name = params[Key::PACKAGE_NAME]
				version_code = params[Key::VERSION_CODE]

				# https://api.eum-appdynamics.com/v2/account/<MyAccountName>/<androidPackageName>/<versionCode>/proguard-mapping
				url = "#{host}/#{version}/account/#{api_account_name}/#{package_name}/#{version_code}/proguard-mapping"

				mapping_path = params[Key::MAPPING_PATH]
				mapping_paths = params[Key::MAPPING_PATHS] || []
				mapping_paths << mapping_path unless mapping_path.nil?
				mapping_paths = mapping_paths.map { |path| File.absolute_path(path) }

				mapping_paths.each do |path|
					UI.user_error!("Mapping file does not exist at path: #{path}") unless File.exist?(path)
				end

				mapping_paths.compact.uniq.map do |mapping|
					UI.message("Uploading mapping: #{mapping}")

					error = nil

					begin
						response = connection.put(url) do |request|
							content_type = 'text/plain'
							request.headers[:content_type] = content_type
							request.headers[:content_length] = File.size(mapping).to_s
							request.body = Faraday::UploadIO.new(mapping, content_type)
						end

						UI.success "Successfully uploaded mapping file: #{response.status} - #{response.reason_phrase}" if response.success?
					rescue => e
						error = e
						UI.error(e)
					end

					self.validate(error: error, error_message: 'Error while trying to upload mapping', fail_on_error: params[Key::FAIL_ON_ERROR])
				end
			end
		end
	end
end
