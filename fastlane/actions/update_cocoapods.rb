require 'json'

module Fastlane
  module Actions
    class UpdateCocoapodsAction < Action

      def self.run(params)

        sh("make", "pod-install")

        target_options = get_target_options
        if target_options.nil?
          return
        end

        sh({ "PODS_BUILD_TARGETS" => target_options }, "make", "pod-build")

        if params[:push]
          other_action.git_add(path: ["Podfile.lock", "Pods"])
          other_action.git_commit(path: ["Podfile.lock", "Pods"], message: "[CI] Update Pods")
          other_action.push_to_git_remote(tags: false)
        end
      end

      def self.get_target_options
        alltargets = ""
        nothing = nil

        unless File.exist? "Pods/xcodebuild.version"
          UI.important "Pods/xcodebuild.version が見つかりません"
          return alltargets
        end

        unless system "git", "diff", "--quiet", "--exit-code", "Pods/xcodebuild.version"
          UI.important 'Pods/xcodebuild.version に変更があります'
          return alltargets
        end

        changed = []
        result = `ruby scripts/cocoapods/pod-checksum.rb`
        result.lines do |line|
          podname = line.split(" ").first
          changed.push(podname) unless podname.empty?
        end

        if changed.empty?
          UI.success "Pods は最新の状態です"
          return nothing
        end

        return changed.map { |podname| "#{podname}" }.join(" ")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
              key: :push,
              description: "trueを指定した場合は自動的にcommitとpushを行う",
              optional: true,
              default_value: false,
              is_string: false
          ),
        ]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "XcodeGen用のプロジェクト定義にCocoaPodsテンプレートが正しく設定されているかを確認する"
      end
    end
  end
end
