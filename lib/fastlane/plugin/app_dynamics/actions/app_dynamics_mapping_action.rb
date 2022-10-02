require 'fastlane/action'
require_relative '../helper/app_dynamics_helper'

module Fastlane

	module Actions

		class AppDynamicsMappingAction < Action

			Helper = Fastlane::Helper::AppDynamicsHelper

			def self.run(params)
				FastlaneCore::PrintTable.print_values(
					config: params,
					title: 'App Dynamics Mapping Summary'
				)

				Helper::upload_mappings(params)
			end

			# Fastlane Action

			def self.description
				'Upload Android mapping files to AppDynamics'
			end

			def self.authors
				['UpBra']
			end

			def self.return_value
				'None'
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::API_HOST,
						env_name: 'APP_DYNAMICS_HOST',
						description: 'API host url for AppDynamics',
						type: String,
						default_value: Helper::DEFAULT_HOST
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::API_VERSION,
						env_name: 'APP_DYNAMICS_API_VERSION',
						description: 'API version for AppDynamics',
						type: String,
						default_value: Helper::DEFAULT_VERSION
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::API_ACCOUNT_NAME,
						env_name: 'APP_DYNAMICS_ACCOUNT_NAME',
						description: 'Account name for AppDynamics',
						type: String
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::API_LICENSE_KEY,
						env_name: 'APP_DYNAMICS_LICENSE_KEY',
						description: 'License key for AppDynamics',
						type: String,
						sensitive: true
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::PACKAGE_NAME,
						env_name: 'APP_DYNAMICS_PACKAGE_NAME',
						description: 'Package name of the app',
						type: String
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::VERSION_CODE,
						env_name: 'APP_DYNAMICS_VERSION_CODE',
						description: 'Version code of the app',
						type: String
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::MAPPING_PATH,
						env_name: 'APP_DYNAMICS_MAPPING_PATH',
						description: 'The path to the mapping file',
						type: String,
						default_value: Actions.lane_context[SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH]
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::MAPPING_PATHS,
						env_name: 'APP_DYNAMICS_MAPPING_PATHS',
						description: 'Array of paths to mapping files',
						type: Array,
						default_value: Actions.lane_context[SharedValues::GRADLE_ALL_MAPPING_TXT_OUTPUT_PATHS],
						optional: true
					)
				]
			end

			def self.is_supported?(platform)
				[:ios, :mac, :tvos].include?(platform)
			end
		end
	end
end
