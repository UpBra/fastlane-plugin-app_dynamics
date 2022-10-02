describe Fastlane::Actions::AppDynamicsAction do
	describe '#run' do
		it 'prints a message' do
			expect(Fastlane::UI).to receive(:message).with("The app_dynamics plugin is working!")

			Fastlane::Actions::AppDynamicsAction.run(nil)
		end
	end
end
