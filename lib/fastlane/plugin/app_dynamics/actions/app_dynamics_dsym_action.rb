require 'fastlane/action'
require_relative '../helper/app_dynamics_helper'

module Fastlane

	module Actions

		class AppDynamicsDsymAction < Action

			Helper = Fastlane::Helper::AppDynamicsHelper

			def self.run(params)
				FastlaneCore::PrintTable.print_values(
					config: params,
					title: 'App Dynamics DSYM Summary'
				)

				Helper::upload_dsyms(params)
			end

			# Fastlane Action

			def self.description
				'Upload dSYM symbolication files to AppDynamics'
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
						key: Helper::Key::DSYM_PATH,
						env_name: 'APP_DYNAMICS_DSYM_PATH',
						description: 'The path to the dSYM or dSYM.zip file',
						type: String,
						default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::DSYM_PATHS,
						env_name: 'APP_DYNAMICS_DSYM_PATHS',
						description: 'Array of paths to dSYM files',
						type: String,
						default_value: Actions.lane_context[SharedValues::DSYM_PATHS],
						optional: true
					),
					FastlaneCore::ConfigItem.new(
						key: Helper::Key::FAIL_ON_ERROR,
						env_name: 'APP_DYNAMICS_FAIL_ON_ERROR',
						description: 'Fail on error',
						type: Boolean,
						default_value: true
					)
				]
			end

			def self.is_supported?(platform)
				[:ios, :mac, :tvos].include?(platform)
			end
		end
	end
end
